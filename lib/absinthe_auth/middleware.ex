defmodule AbsintheAuth.Middleware do
  @moduledoc false
  @behaviour Absinthe.Middleware
  @behaviour Absinthe.Plugin

  def call(resolution, {module, args}) do
    resolution
    |> module.call(args)
    |> maybe_continue_authorisation
  end

  def maybe_continue_authorisation(%{private: %{authorisation: :done}} = resolution) do
    if pending_authorisation_checks?(resolution) do
      resolution
    else
      resolution
      |> finish_authorisation
      |> maybe_push_middleware
    end
  end

  def maybe_continue_authorisation(%{private: %{authorisation: :pending}} = resolution) do
    if pending_authorisation_checks?(resolution) do
      resolution
    else
      resolution
      |> finish_authorisation
      |> Absinthe.Resolution.put_result({:error, "Denied"})
    end
  end

  def maybe_continue_authorisation(resolution) do
    # No explicit authorisation took place - maybe we don't deny this?
    resolution
    |> finish_authorisation
    |> Absinthe.Resolution.put_result({:error, "Denied"})
  end

  def maybe_push_middleware(%{definition: definition} = resolution) do
    case resolution.middleware do
      [_ | _] ->
        resolution

      [] ->
        field = String.to_atom(definition.name)
        # Insert default middleware

        resolution
        |> push_middleware({Absinthe.Middleware.MapGet, field})
    end
  end

  # TODO: storing the authorisation state might be better in the private field

  def pending_authorisation_checks?(%{middleware: middleware}) do
    Enum.any?(middleware, fn
      {{AbsintheAuth.Middleware, :call},_} ->
        true
      _ ->
        false
    end)
  end

  defp finish_authorisation(%{private: private} = resolution) do
    %{resolution | private: Map.delete(private, :authorisation)}
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
