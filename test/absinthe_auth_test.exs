defmodule AbsintheAuthTest do
  use AbsintheAuthTest.GraphQLCase
  doctest AbsintheAuth

  describe "querying a single record" do
    @query """
      {
        movie(id: 1) {
          title
          budget
        }
      }
    """
    test "is successful" do
      Movies.Schema
      |> run_query(@query)
      |> assert_success
    end

    test "has budget restricted by default" do
      @query
      |> Absinthe.run(Movies.Schema)
      |> assert_success
      |> assert_field_error(["movie", "budget"], "Denied")
    end

    test "has budget visible with the producer permission" do
      @query
      |> Absinthe.run(Movies.Schema, context: %{permissions: [:producer]})
      |> assert_success
      |> assert_field(["movie", "budget"], 63_000_000)
    end

    test "has title visible" do
      @query
      |> Absinthe.run(Movies.Schema)
      |> assert_field(["movie", "title"], "The Matrix")
    end
  end

  describe "querying list of records" do
    @query """
      {
        movies {
          title
          budget
        }
      }
    """
    test "is successful" do
      Movies.Schema
      |> run_query(@query)
      |> assert_success
    end

    test "has budget restricted by default on all records" do
      @query
      |> Absinthe.run(Movies.Schema)
      |> assert_success
      |> assert_field_error(["movies", 0, "budget"], "Denied")
      |> assert_field_error(["movies", 1, "budget"], "Denied")
      |> assert_field_error(["movies", 2, "budget"], "Denied")
      |> assert_field_error(["movies", 3, "budget"], "Denied")
    end

    test "has budget visible on records where the current user is the producer" do
      @query
      |> Absinthe.run(Movies.Schema) # TODO: perms or current user?
      |> assert_success
      |> assert_field_error(["movies", 0, "budget"], "Denied")
      |> assert_field_error(["movies", 1, "budget"], "Denied")
      |> assert_field_error(["movies", 2, "budget"], "Denied")
      |> assert_field_error(["movies", 3, "budget"], "Denied")
    end
  end
end
