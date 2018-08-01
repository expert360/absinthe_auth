defmodule AbsintheAuthTest.MutationTest do
  use AbsintheAuthTest.GraphQLCase
  import AbsintheAuthTest.SetupHelpers
  doctest AbsintheAuth

  import ExUnit.CaptureIO

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
      refute capture_io(fn ->
        @query
        |> Absinthe.run(Movies.Schema, variables: %{
          "title" => "Infinity War",
          "budget" => 321_000_000
        })
        |> assert_success
        |> assert_field_error(["createMovie"], "Denied")
      end) =~ "Creating Movie"
    end
  end

  describe "when the viewer has the studio grant" do
    setup [:viewer_is_studio_manager]

    test "that the mutation does not run", %{context: context} do
      assert capture_io(fn ->
        @query
        |> Absinthe.run(Movies.Schema, context: context, variables: %{
          "title" => "Infinity War",
          "budget" => 321_000_000
        })
        |> IO.inspect
        |> assert_success
        |> assert_field(["createMovie", "title"], "Infinity War")
        #|> assert_field(["createMovie", "budget"], 321_000_000) # TODO
      end) =~ "Creating Movie"
    end
  end
end
