defmodule AbsintheAuth.Policy do
  @moduledoc """
  Helper functions for use in policies.

  ## Usage
  
  ```
  defmodule MyPolicy do
    use AbsintheAuth.Policy
  end
  ```
  """

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  @doc """
  Allows a request

  For example:

  ```
  def check(resolution, _opts) do
    allow!(resolution)
  end
  ```
  """
  @spec allow!(resolution :: Absinthe.Resolution.t) :: Absinthe.Resolution.t
  def allow!(%{private: private} = resolution) do
    %{resolution | private: Map.put(private, :authorisation, :done)}
  end

  @doc """
  Denies a request

  For example:

  ```
  def check(resolution, _opts) do
    deny!(resolution)
  end
  ```
  """
  @spec deny!(resolution :: Absinthe.Resolution.t) :: Absinthe.Resolution.t
  def deny!(resolution) do
    Absinthe.Resolution.put_result(resolution, {:error, "Denied"})
  end

  # TODO: Don't force defer in the middleware (let policy implementors decide)
  @doc """
  Defers a request for a decision in a subsequent policy.
  If no decision is made the request will be denied.

  For example:

  ```
  def check(resolution, _opts) do
    defer!(resolution)
  end
  ```
  """
  @spec defer(resolution :: Absinthe.Resolution.t) :: Absinthe.Resolution.t
  def defer(%{private: private} = resolution) do
    %{resolution | private: Map.put(private, :authorisation, :pending)}
  end

  @doc """
  Returns true if the current request is a mutation"
  """
  @spec is_mutation?(resolution :: Absinthe.Resolution.t) :: boolean
  def is_mutation?(resolution) do
    resolution.parent_type.identifier == :mutation
  end

  @doc """
  Fetches an argument from the current resolution.

  Say we have a schema as follows:

  ```
  query do
    field :movie, :movie do
      arg :id, non_null(:id)
      policy MoviePolicy, :view
      resolve &MovieResolver.find_movie/2
    end
  end
  ```

  In our policy we can fetch the `id` used that passed to the request:

  ```
  defmodule MoviePolicy do
    use AbsintheAuth.Policy

    def view(resolution, _) do
      id = arg(resolution, id)
      SomeModule.that_checks_if_we_can_view_this_movie(id)
    end
  end
  ```
  """
  def arg(resolution, arg) do
    # TODO: Ideally we'd cast the argument to the type defined in the schema
    # (By default we get a string here)
    get_in(resolution.arguments, List.wrap(arg))
  end
end
