defmodule AbsintheAuthTest.PostResolutionPolicyTest do
  use AbsintheAuthTest.GraphQLCase
  import AbsintheAuthTest.SetupHelpers
  doctest AbsintheAuth

  alias Movies.Schema

  @query """
    query movieById($id: ID!) {
      movie: movie2(id: $id) {
        title
        budget
      }
    }
  """

  describe "a released movie" do
    setup [:viewer_is_producer]

    test "is viewable but budget is hidden", %{context: context} do
      @query
      |> Absinthe.run(Schema, variables: %{"id" => 2}, context: context)
      |> assert_success
      |> assert_field_error(["movie", "budget"], "Denied")
      |> assert_field(["movie", "title"], "Star Wars")
    end

    test "budget is visible for a movie she produced", %{context: context} do
      @query
      |> Absinthe.run(Schema, variables: %{"id" => 1}, context: context)
      |> assert_success
      |> assert_field(["movie", "budget"], 63_000_000)
      |> assert_field(["movie", "title"], "The Matrix")
    end
  end

  describe "an unreleased movie (where the user is logged out)" do
    test "is hidden" do
      @query
      |> Absinthe.run(Schema, variables: %{"id" => 5})
      |> assert_success
      |> assert_field_error(["movie"], "Denied")
    end
  end

  describe "an unreleased movie where the viewer is the producer" do
    setup [:viewer_is_producer]

    test "is still visible to the producer", %{context: context} do
      @query
      |> Absinthe.run(Schema, variables: %{"id" => 5}, context: context)
      |> assert_success
      |> assert_field(["movie", "budget"], 100_000_000)
      |> assert_field(["movie", "title"], "Avatar 23")
    end
  end
end
