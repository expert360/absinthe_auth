defmodule AbsintheAuth.Middleware.Policy do
  @behaviour Absinthe.Middleware

  # TODO: Handle FunctionClauseError
  # TODO: This thing is probably not needed - just put this in the main middleware
  def call(resolution, {module, func, opts}) do
    apply(module, func, [resolution, resolution.source, opts])
  end
end
