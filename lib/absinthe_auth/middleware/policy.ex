defmodule AbsintheAuth.Middleware.Policy do
  @behaviour Absinthe.Middleware

  # TODO: Handle FunctionClauseError
  # TODO: This thing is probably not needed - just put this in the main middleware
  def call(resolution, {module, func, opts}) do
    IO.inspect(resolution.parent_type, label: "Parent Type")
    IO.inspect(resolution.source, label: "Source")
    if resolution.parent_type.identifier in [:query, :mutation] do
      apply(module, func, [resolution, opts])
    else
      apply(module, func, [resolution, resolution.source, opts])
    end
  end
end
