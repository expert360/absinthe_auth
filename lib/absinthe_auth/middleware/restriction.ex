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
  defp verify_permission(resolution, {permission, scope}, requested_scope) do
    with {:ok, acl} <- load_acl(resolution) do
      acl.verify_permission({permission, scope}, requested_scope)
    else
      _ ->
        false
    end
  end

  # TODO: This should handle the permissions being a list of typles
  # rather than a single Map
  # The trick then will be handling if we have many permissions (say with different scopes)
  # In that case we should use Enum.any? to see if any of them grant access
  #
  # permissions
  # |> Keyword.get_values(permission)
  # |> Enum.any?(fn scope -> acl.verify_permission({permission, scope}, requested_scope)
  #
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
