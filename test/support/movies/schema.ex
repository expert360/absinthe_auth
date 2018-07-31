defmodule Movies.Schema do
  use Absinthe.Schema
  use AbsintheAuth
  alias Movies.Database

  def plugins do
    [AbsintheAuth.Middleware] ++ Absinthe.Plugin.defaults()
  end

  query do
    field :movies, list_of(:movie) do
      resolve fn _, _ ->
        {:ok, Database.get_movies()}
      end
    end

    field :movie, :movie do
      arg :id, non_null(:integer)
      resolve fn %{id: id}, _ ->
        {:ok, Database.get_movie(id)}
      end
    end
  end

  object :movie do
    field :title, :string
    field :budget, :integer do
      allow_only [:producer, :director]
    end
  end
end
