defmodule Movies.Database do
  alias Movies.Movie

  def get_movies do
    [
      %Movie{id: 1, title: "The Matrix", budget: 63_000_000, producer_id: 100},
      %Movie{id: 2, title: "Star Wars", budget: 11_000_000, producer_id: 200},
      %Movie{id: 3, title: "Gone with the Wind", budget: 4_000_000, producer_id: 300},
      %Movie{id: 4, title: "Clueless", budget: 12_000_000, producer_id: 400},
    ]
  end

  def get_movie(target_id) do
    Enum.find(get_movies(), fn %{id: id} ->
      int(target_id) == id
    end)
  end

  def create_movie(args) do
    IO.puts("Creating Movie")
    struct(Movie, args)
  end

  defp int(arg) when is_integer(arg) do
    arg
  end
  defp int(arg) do
    {ret, _} = Integer.parse(arg)
    ret
  end
end
