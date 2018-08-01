defmodule AbsintheAuth.ACL do
  @typedoc """
  Defines a permission with a given scope

  ## Examples

  ```
  {:manager, %Project{}}
  {:admin, %Organisation{}}
  {:view, :all}
  ```
  """
  @type permission :: {atom(), scope()}

  @typedoc """
  Defines a scope to be used in a permission
  """
  @type scope :: :all | atom() | struct()

  @doc """
  Defines how permissions for a request should be loaded.
  The permissions are set on the `Absinthe.Resolution` struct inside
  the `context` each time a request is made.

  This function takes the `context` (map) as an argument in case
  useful information from the request is needed (such as the current user).

  ## Example
  
  ```
  def load_permissions(%{current_user: %{id: id}}) do
    Permission
    |> where([p], p.user_id == ^id)
    |> select([p], {p.permission, p.target_type, p.target_id})
    |> Repo.all
    |> Enum.map(fn
      {permission, "all", nil} ->
        {String.to_atom(permission), :all}

      {permission, target_type, id} ->
        {
          String.to_atom(permission),
          "Elixir." <> target_type |> String.to_existing_atom |> struct(id: id)
        }
    end)
  end
  ```
  """
  @callback load_permissions(Map.t) :: [permission()]

  # TODO: rename to grant?
  # grant?({permission, scope}, for: target)
  @callback verify_permission(permission, scope) :: true | false
end
