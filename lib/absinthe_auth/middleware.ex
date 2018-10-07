defmodule AbsintheAuth.Middleware do
  @moduledoc false
  @behaviour Absinthe.Middleware
  @behaviour Absinthe.Plugin

  def call(%{private: %{authorisation: :done}} = resolution, _) do
    maybe_push_middleware(resolution)
  end
  def call(resolution, {module, args}) do
    resolution
    |> module.call(args)
    |> maybe_continue_authorisation
  end

  def maybe_continue_authorisation(%{private: %{authorisation: :done}} = resolution) do
    maybe_push_middleware(resolution)
  end

  def maybe_continue_authorisation(%{private: %{authorisation: :pending}} = resolution) do
    if pending_authorisation_checks?(resolution) do
      resolution
    else
      Absinthe.Resolution.put_result(resolution, {:error, "Denied"})
    end
  end

  def maybe_continue_authorisation(resolution) do
    # No explicit authorisation took place - it was only deferred so we deny
    Absinthe.Resolution.put_result(resolution, {:error, "Denied"})
  end

  def maybe_push_middleware(%{state: :resolved} = resolution) do
    # No need to the resolution middleware if we have already resolved
    resolution
  end
  def maybe_push_middleware(%{definition: definition} = resolution) do
    case resolution.middleware do
      [_ | _] ->
        # Additional middleware remain to be processed
        # Let's continue
        resolution

      [] ->
        field = definition.schema_node.identifier

        # Insert default middleware
        push_middleware(resolution, {Absinthe.Middleware.MapGet, field})
    end
  end

  def pending_authorisation_checks?(%{middleware: middleware}) do
    Enum.any?(middleware, fn
      {{AbsintheAuth.Middleware, :call},_} ->
        true
      _ ->
        false
    end)
  end

  defp push_middleware(resolution, middleware) do
    %{resolution | middleware: [middleware | resolution.middleware]}
  end

  def after_resolution(exec) do
    exec
  end

  def before_resolution(exec) do
    exec
  end

  def pipeline(pipeline, _) do
    pipeline
  end
end
