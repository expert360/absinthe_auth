defmodule Movies.Movie do
  defstruct [:id, :title, :budget, :producer_id]

  defimpl AbsintheAuth.Permission do
    def allow?(%Movies.Movie{}, permission, %{context: context}) do
      with %{permissions: permissions} <- context do
        Enum.member?(permissions, permission)
      else
        _ ->
        false
      end
    end
  end
end
