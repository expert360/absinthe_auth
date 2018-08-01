defmodule AbsintheAuthTest.MutationTest do
  use AbsintheAuthTest.GraphQLCase
  import AbsintheAuthTest.SetupHelpers
  doctest AbsintheAuth

  @query """
    mutation CreateMovie($title: String!, $budget: Int!) {
      createMovie(title: $title, budget: $budget) {
        title
        budget
      }
    }
  """

  describe "when the viewer is not set (logged out)" do
    test "that the mutation does not run" do
      @query
      |> Absinthe.run(Movies.Schema, variables: %{
        "title" => "Infinity War",
        "budget" => 321_000_000
      })
      |> assert_success
      |> IO.inspect
    end

    # TODO: Check that it didn't resolve
  end
end
