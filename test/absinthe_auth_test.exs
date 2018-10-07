defmodule AbsintheAuthTest do
  use AbsintheAuthTest.GraphQLCase
  import AbsintheAuthTest.SetupHelpers
  doctest AbsintheAuth

  alias Movies.Schema

  @query """
    query movieById($id: ID!) {
      movie(id: $id) {
        title
        budget
        boxOffice
      }
    }
  """

  describe "when the viewer is not set (logged out)" do
    test "movie budget is restricted" do
      @query
      |> Absinthe.run(Schema, variables: %{"id" => 1})
      |> assert_success
      |> assert_field_error(["movie", "budget"], "Denied")
      |> assert_field_error(["movie", "boxOffice"], "Denied")
    end

    test "movie title is visible" do
      @query
      |> Absinthe.run(Schema, variables: %{"id" => 1})
      |> assert_success
      |> assert_field(["movie", "title"], "The Matrix")
    end
  end

  describe "when the viewer is a producer" do
    setup [:viewer_is_producer]

    test "budget is restricted for a movie she didn't produce", %{context: context} do
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
      |> assert_field(["movie", "boxOffice"], 463_000_000)
      |> assert_field(["movie", "title"], "The Matrix")
    end
  end

  describe "when the viewer is a studio manager" do
    setup [:viewer_is_studio_manager]

    test "budget is visible", %{context: context} do
      @query
      |> Absinthe.run(Schema, variables: %{"id" => 2}, context: context)
      |> assert_success
      |> assert_field(["movie", "budget"], 11_000_000)
      |> assert_field(["movie", "title"], "Star Wars")
    end
  end

  # TODO: More tests
  # - test a director role that has access to genre object field
  # - and with a custom scope
end
