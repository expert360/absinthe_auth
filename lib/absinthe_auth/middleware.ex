defmodule AbsintheAuth.Middleware do
  @behaviour Absinthe.Middleware
  @behaviour Absinthe.Plugin

  # TODO: Handle if resolution itself returns an error
  # e.g. if the resolver returns {:error, "foo"}

  # The approach here is a bit inefficient - we always resolve before
  # restricting. That's really only needed if the resolved value
  # is required to make an access decision. Otherwise we shouldn't resolve
  #

  def call(%{definition: definition} = resolution, {module, args}) do
    resolution
    |> module.call(args)
    |> maybe_continue_authorisation
  end

  def maybe_continue_authorisation(%{context: %{authorisation: :done}} = resolution) do
    if pending_authorisation_checks?(resolution) do
      resolution
    else
      resolution
      |> finish_authorisation
      |> maybe_push_middleware
    end
  end

  def maybe_continue_authorisation(%{context: %{authorisation: :pending}} = resolution) do
    if pending_authorisation_checks?(resolution) do
      resolution
    else
      resolution
      |> finish_authorisation
      |> Absinthe.Resolution.put_result({:error, "Denied"})
    end
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

  defp finish_authorisation(resolution) do
    %{resolution | context: Map.delete(resolution.context, :authorisation)}
  end

  defp push_middleware(resolution, middleware) do
    %{resolution | middleware: [middleware | resolution.middleware]}
  end

  def after_resolution(exec) do
    exec
  end

  def before_resolution(%{context: context} = exec) do
    context =
      with %{acl: acl} <- context do
        Map.put(context, :permissions, acl.load_permissions(context))
      end

    %{exec | context: context}
  end

  def pipeline(pipeline, _) do
    pipeline
  end

  defp flush_middleware(resolution) do
    %{resolution | middleware: []}
  end
end
