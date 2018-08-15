defmodule Movies.Schema do
  use Absinthe.Schema
  use AbsintheAuth
  alias Movies.Database
  alias Movies.Policy.Permit

  def plugins do
    [AbsintheAuth.Middleware] ++ Absinthe.Plugin.defaults()
  end

  query do
    field :movies, list_of(:movie) do
      policy Permit, :view

      resolve fn _, _ ->
        {:ok, Database.get_movies()}
      end
    end

    field :movie, :movie do
      arg :id, non_null(:id)
      policy Permit, :view

      resolve fn %{id: id}, _ ->
        {:ok, Database.get_movie(id)}
      end
    end
  end

  mutation do
    field :create_movie, :movie do
      arg :title, :string
      arg :budget, :integer

      policy Permit, :create

      resolve fn args, _ ->
        {:ok, Database.create_movie(args)}
      end
    end
  end

  object :movie do
    field :id, non_null(:id)
    field :title, :string
    field :budget, :integer do
      policy Permit, :budget
    end
    field :genre, :genre do
      resolve fn _, _ ->
        {:ok, %{}} # TODO
      end
    end
  end

  object :genre do
    field :id, non_null(:id)
    field :name, non_null(:string)
  end
end
