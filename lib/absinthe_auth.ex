defmodule AbsintheAuth do
  @moduledoc """

  Macros to add policies to your `Absinthe` GraphQL schema.
  See [documentation](https://hexdocs.pm/absinthe_auth) for more details.
  """

  alias Absinthe.Schema.Notation
  alias AbsintheAuth.Middleware

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  @doc """
  Add a policy to the current field. Only works inside the block with a call to `field`.
  Assumes that `Absinthe.Schema` or `Absinthe.Schema.Notation` has been imported to the module.

  ```elixir
  field :name, :string do
    policy Admin, :allow
  end
  ```
  """
  defmacro policy(module, func, opts \\ []) do
    quote do
      Notation.middleware(
        Middleware,
        {Middleware.Policy, {unquote(module), unquote(func), unquote(opts)}}
      )
    end
  end
end
