defmodule AbsintheAuth.Middleware.Restriction do
  @behaviour Absinthe.Middleware

  # No need to perform additional checks
  # if an authorisation outcome has already been determined
  def call(%{context: %{authorisation: :done}} = resolution, _) do
    resolution
  end

  def call(resolution, {permission, opts}) do
    if check?(resolution, permission, opts) do
      auth_success(resolution)
    else
      auth_pending(resolution)
    end
  end

  defp check?(resolution, permission, opts) do
    requested_scope = Keyword.get(opts, :scope, resolution.source)

    resolution
    |> fetch_permission_from_context(permission)
    |> Enum.any?(&verify_permission(resolution, {permission, &1}, requested_scope))
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
  defp verify_permission(resolution, {permission, scope}, requested_scope) do
    with {:ok, acl} <- load_acl(resolution) do
      acl.verify_permission({permission, scope}, requested_scope)
    else
      _ ->
        false
    end
  end

  defp fetch_permission_from_context(%{context: context}, permission) do
    with %{permissions: permissions} <- context do
      Keyword.get_values(permissions, permission)
    else
      _ ->
        []
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
