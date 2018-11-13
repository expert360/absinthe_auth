defmodule AbsintheAuth.Middleware do
  @moduledoc false
  @behaviour Absinthe.Middleware
  @behaviour Absinthe.Plugin

  def call(%{private: %{authorisation: :done}} = resolution, _) do
    maybe_append_middleware(resolution)
  end
  def call(resolution, {module, args}) do
    resolution
    |> module.call(args)
    |> maybe_continue_authorisation
  end

  def maybe_continue_authorisation(%{private: %{authorisation: :done}} = resolution) do
    maybe_append_middleware(resolution)
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

  def maybe_append_middleware(%{state: :resolved} = resolution) do
    # No need to the resolution middleware if we have already resolved
    resolution
  end
  def maybe_append_middleware(%{definition: definition} = resolution) do
    has_no_resolution_mware? = not Enum.any?(resolution.middleware, fn
      {{Absinthe.Middleware.MapGet, _}, _} ->
        true
      {{Absinthe.Resolution, _}, _} ->
        true
      _ ->
        false
    end)
    if Enum.empty?(resolution.middleware) || has_no_resolution_mware? do
      # We do not know if we may get a resolution out of the further middleware,
      # the MapGet default middleware is idempotent if a resolution has
      # already occured, so we stuff it at the end of all possible middleware
      field = definition.schema_node.identifier
      append_middleware(resolution, {Absinthe.Middleware.MapGet, field})
    else
      resolution
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

  defp append_middleware(resolution, middleware) do
    %{resolution | middleware: resolution.middleware ++ [middleware]}
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
