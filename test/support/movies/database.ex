defmodule Movies.Database do
  alias Movies.Movie

  def get_movies do
    [
      %Movie{
        id: 1,
        title: "The Matrix",
        budget: 63_000_000,
        box_office: 463_000_000,
        producer_id: "producer",
        released: true
      },
      %Movie{
        id: 2,
        title: "Star Wars",
        budget: 11_000_000,
        box_office: 1_600_000_000,
        producer_id: 200,
        released: true
      },
      %Movie{
        id: 3,
        title: "Gone with the Wind",
        budget: 4_000_000,
        box_office: 1_800_000_000,
        producer_id: 300,
        released: true
      },
      %Movie{
        id: 4,
        title: "Clueless",
        budget: 12_000_000,
        box_office: 56_000_000,
        producer_id: 400,
        released: true
      },
      %Movie{
        id: 5,
        title: "Avatar 23",
        budget: 100_000_000,
        box_office: 0,
        producer_id: "producer",
        released: false
      },
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
