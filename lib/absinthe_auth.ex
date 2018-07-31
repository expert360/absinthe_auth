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

  defmacro allow_only(permissions) do
    quote do
      Notation.middleware(Middleware, {Middleware.Restriction, List.wrap(unquote(permissions))})
    end
  end

  defmacro visible do
    quote do
      Notation.middleware(Middleware, {Middleware.Visible, []})
    end
  end

  # TODO: Investigate if this is possible as an alternative syntax
  # 
  # field :name, controlled(:string, only: [:admin, :owner])
  #
  # This would require putting the auth logic into the field parsers
  # rather than a middleware which may not make sense?
  #
  #defmacro controlled(type, only: only) do
  #  quote do
  #    unquote(type)
  #  end
  #end
end
