defmodule AbsintheAuth do
  @moduledoc """
  Documentation for AbsintheAuth.
  """

  alias Absinthe.Schema.Notation
  alias AbsintheAuth.Middleware

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  defmacro permit(permission, opts \\ []) do
    quote do
      Notation.middleware(
        Middleware,
        {Middleware.Restriction, {unquote(permission), unquote(opts)}}
      )
    end
  end
end
