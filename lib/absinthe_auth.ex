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

  defmacro policy(module, func, opts \\ []) do
    quote do
      Notation.middleware(
        Middleware,
        {Middleware.Policy, {unquote(module), unquote(func), unquote(opts)}}
      )
    end
  end

  defmacro permit(permission, opts \\ []) do
    quote do
      Notation.middleware(
        Middleware,
        {Middleware.Permit, {unquote(permission), unquote(opts)}}
      )
    end
  end
end
