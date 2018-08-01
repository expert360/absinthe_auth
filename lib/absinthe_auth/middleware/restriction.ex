defmodule AbsintheAuth.Middleware.Restriction do
  @behaviour Absinthe.Middleware

  alias Absinthe.Resolution
  alias AbsintheAuth.Permission

  def call(resolution, {permission, opts}) do
    IO.puts("Checking Permission: #{permission}")

    case check?(resolution, permission, opts) do
      true ->
        IO.puts("...true")
        auth_success(resolution)

      false ->
        IO.puts("...false")
        auth_pending(resolution)
    end
  end

  defp check?(resolution, permission, opts) do
    requested_scope = Keyword.get(opts, :scope, resolution.source)

    case fetch_permission_from_context(resolution, permission) do
      {:ok, scope} ->
        verify_permission(resolution, {permission, scope}, requested_scope)
      :error ->
        false
    end
  end

  defp load_acl(%{context: context}) do
    case Map.fetch(context, :acl) do
      {:ok, acl} ->
        {:ok, acl}

      _ ->
        # Log a warning or raise?
        :error
    end
  end

  # TODO: Create types
  defp verify_permission(resolution, permission, requested_scope) do
    with {:ok, acl} <- load_acl(resolution) do
      acl.verify_permission(permission, requested_scope)
    else
      _ ->
        false
    end
  end

  defp fetch_permission_from_context(%{context: context}, permission) do
    with %{permissions: permissions} <- context do
      Map.fetch(permissions, permission)
    else
      _ ->
        :error
    end
  end

  defp auth_success(resolution) do
    %{resolution | context: Map.put(resolution.context, :authorisation, :done)}
  end

  defp auth_pending(%{context: %{authorisation: :done}} = resolution) do
    resolution
  end
  defp auth_pending(resolution) do
    %{resolution | context: Map.put(resolution.context, :authorisation, :pending)}
  end
end
