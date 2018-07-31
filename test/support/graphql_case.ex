defmodule AbsintheAuthTest.GraphQLCase do
  use ExUnit.CaseTemplate

  defmacro __using__(opts) do
    quote do
      use ExUnit.Case, async: false

      def run_query(schema, query) do
        Absinthe.run(query, schema)
      end

      def assert_success({:ok, _body} = res) do
        assert true
        res
      end
      def assert_success({:error, error} = res) do
        flunk "Graph query failed: '#{error}'"
        res
      end

      def assert_field_error({:ok, %{errors: errors}} = res, target_path, message) do
        error = Enum.find(errors, fn %{path: path} ->
          path == target_path
        end)
        assert(
          error && error.message == message,
          "Expected value at path '#{inspect target_path}' to have error with message '#{message}'"
        )
        res
      end
      def assert_field_error({:ok, _} = res, _, _) do
        flunk "No errors in query response"
        res
      end

      def assert_field({:ok, %{data: data}} = res, target_path, value) do
        assert get_in(data, expand_path(target_path)) == value
      end

      defp expand_path(path) do
        Enum.map(path, fn val ->
          if is_integer(val) do
            Access.at(val)
          else
            val
          end
        end)
      end
    end
  end
end
