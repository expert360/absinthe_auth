defmodule AbsintheAuth.Policy do
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)
    end
  end

  def allow!(%{private: private} = resolution) do
    %{resolution | private: Map.put(private, :authorisation, :done)}
  end

  def deny!(resolution) do
    Absinthe.Resolution.put_result(resolution, {:error, "Denied"})
  end

  # TODO: Don't force defer in the middleware (let policy implementors decide)
  def defer(%{private: private} = resolution) do
    %{resolution | private: Map.put(private, :authorisation, :pending)}
  end

  def is_mutation?(resolution) do
    resolution.parent_type.identifier == :mutation
  end

  def arg(resolution, arg) do
    get_in(resolution.arguments, List.wrap(arg))
  end
end
