defmodule AbsintheAuth.Middleware.Policy do
  @behaviour Absinthe.Middleware

  # TODO: Handle FunctionClauseError
  def call(resolution, {module, func, opts}) do
    if resolution.parent_type.identifier in [:query, :mutation] do
      apply(module, func, [resolution, opts])
    else
      apply(module, func, [resolution, resolution.source, opts])
    end
  end
end
