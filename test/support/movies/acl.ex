defmodule Movies.ACL do
  # TODO: Use a behaviour

  def load_permissions(%{viewer_id: "producer"}) do
    # TODO: Probably should be a list
    %{
      producer: Movies.Database.get_movie(1),
      director: Movies.Database.get_movie(2)
    }
  end

  def load_permissions(%{viewer_id: "studio_manager"}) do
    # TODO: Probably should be a list
    %{
      creator: :all
    }
  end

  # Logged out user
  def load_permissions(_) do
    %{}
  end

  def verify_permission({_grant, :all}, _) do
    true
  end

  def verify_permission({_grant, _scope}, requested_scope) when is_atom(requested_scope) do
    false
  end

  def verify_permission({_grant, scope}, requested_scope) do
    scope == requested_scope
  end
end
