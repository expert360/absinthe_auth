defmodule Movies.Schema do
  use Absinthe.Schema
  use AbsintheAuth
  alias Movies.Database

  defmodule ACL do
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

    def verify_permission({_grant, scope}, requested_scope) when is_atom(requested_scope) do
      false
    end

    def verify_permission({grant, scope}, requested_scope) do
      scope == requested_scope
    end
  end

  def plugins do
    [AbsintheAuth.Middleware] ++ Absinthe.Plugin.defaults()
  end

  def context(context) do
    Map.put(context, :acl, ACL)
  end

  query do
    field :movies, list_of(:movie) do
      resolve fn _, _ ->
        {:ok, Database.get_movies()}
      end
    end

    field :movie, :movie do
      arg :id, non_null(:id)
      resolve fn %{id: id}, _ ->
        {:ok, Database.get_movie(id)}
      end
    end
  end

  mutation do
    field :create_movie, :movie do
      arg :title, :string
      arg :budget, :integer

      permit :creator

      resolve fn args, _ ->
        {:ok, Database.create_movie(args)}
      end
    end
  end

  object :movie do
    field :id, non_null(:id)
    field :title, :string
    field :budget, :integer do
      permit :producer
      permit :creator
    end
  end
end
