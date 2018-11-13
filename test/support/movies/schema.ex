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

    @desc """
    Fetch a movie by its ID and perform pre-resolution policy checks
    """
    field :movie, :movie do
      arg :id, non_null(:id)
      policy Permit, :view

      resolve fn %{id: id}, _ ->
        {:ok, Database.get_movie(id)}
      end
    end

    @desc """
    Fetch a movie by its ID and perform post-resolution policy checks
    """
    field :movie2, :movie do
      arg :id, non_null(:id)

      resolve fn %{id: id}, _ ->
        {:ok, Database.get_movie(id)}
      end
      policy Permit, :released
      policy Permit, :producer
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

    @desc "The movie's budget"
    field :budget, :integer do
      policy Permit, :producer
      policy Permit, :studio_manager
    end

    @desc "How much the movie made at the box office"
    field :box_office, :integer do
      policy Permit, :producer
      policy Permit, :studio_manager
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

  # These middleware do nothing but help test absinthe_auth for the case where
  # there are other middleware at play.
  def do_nothing(resolution, _) do
    resolution
  end

  def middleware(middleware, _, _) do
    middleware ++ [{{__MODULE__, :do_nothing}, []}]
  end
end
