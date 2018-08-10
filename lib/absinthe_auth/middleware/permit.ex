defmodule AbsintheAuth.Middleware.Permit do
  @behaviour Absinthe.Middleware

  defmodule Action do

    # assigned: "project:*"
    # requested: "project:view/budget"
    def match?(requested, assigned) do
      # Make a module var
      pattern = :binary.compile_pattern([":", "."])
      # Only do this one for a set of lookups as we traverse all the perms
      target = String.split(requested, pattern)

      assigned
      |> String.splitter(pattern)
      |> Stream.zip(target)
      |> Enum.all?(fn
        {x, x}   -> true
        {"*", _} -> true
        _        -> false
      end)
    end
  end

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
    %{definition: %{schema_node: %{name: name, args: _args}}} = resolution
    %{parent_type: %{identifier: parent_type}} = resolution

    IO.inspect(name, label: "Requested field")
    IO.inspect(parent_type, label: "Parent Type")

    resolution
    |> fetch_permission_from_context(permission)
    |> IO.inspect(label: "permissions")
    #|> Enum.any?(&verify_permission(resolution, {permission, &1}, requested_scope))

    true
  end

  defp fetch_permission_from_context(%{context: context}, action) do
    with %{permissions: permissions} <- context do
      Enum.flat_map(permissions, fn {permitted_action, resource} ->
        if Action.match?(action, permitted_action) do
          [resource]
        else
          :error
        end
      end)
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
