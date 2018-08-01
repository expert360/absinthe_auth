defmodule AbsintheAuth.Middleware.Restriction do
  @behaviour Absinthe.Middleware

  alias Absinthe.Resolution
  alias AbsintheAuth.Permission

  def call(resolution, {permission, opts}) do
    case check?(resolution, permission, opts) do
      true ->
        finish_auth(resolution)

      false ->
        resolution
        |> finish_auth
        |> Resolution.put_result({:error, "Denied"})
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
    IO.inspect(context, label: "Context")

    with %{permissions: permissions} <- context do
      Map.fetch(permissions, permission)
    else
      _ ->
        :error
    end
  end

  defp finish_auth(resolution) do
    %{resolution | context: Map.put(resolution.context, :authorisation, :done)}
  end
end
