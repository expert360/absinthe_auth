defmodule AbsintheAuth.Middleware do
  @moduledoc false
  @behaviour Absinthe.Middleware
  @behaviour Absinthe.Plugin

  def call(%{private: %{authorisation: :done}} = resolution, _) do
    resolution
  end

  # authorisation pending - call the policy module and check the result
  def call(%{private: %{authorisation: :pending}} = resolution, {module, args}) do
    resolution
    |> module.call(args)
    |> maybe_continue_authorisation
  end

  # No authorisation - init auth state to :pending, install middleware to reset after resolution
  def call(%{private: private} = resolution, {module, args}) do
    private = Map.put(private, :authorisation, :pending)
    reset_middleware = {{AbsintheAuth.Middleware, :reset}, nil}

    resolution = %{
      resolution
      | private: private,
        middleware: resolution.middleware ++ [reset_middleware]
    }

    call(resolution, {module, args})
  end

  # reset the private.authorisation field in the resolution
  def reset(%{private: private} = resolution, _) do
    %{resolution | private: Map.delete(private, :authorisation)}
  end

  # Authorized - continue
  def maybe_continue_authorisation(%{private: %{authorisation: :done}} = resolution) do
    resolution
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

  def pending_authorisation_checks?(%{middleware: middleware}) do
    Enum.any?(middleware, &match?({{AbsintheAuth.Middleware, :call}, _}, &1))
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
