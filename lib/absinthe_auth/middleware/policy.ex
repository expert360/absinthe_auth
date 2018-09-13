defmodule AbsintheAuth.Middleware.Policy do
  @moduledoc false
  @behaviour Absinthe.Middleware

  def call(resolution, {module, func, opts}) do
    apply(
      module,
      func,
      policy_args(resolution) ++ [opts]
    )
  end

  defp policy_args(%{state: :resolved} = resolution) do
    [resolution, resolution.value]
  end
  defp policy_args(%{parent_type: %{identifier: ident}} = resolution)
  when ident in [:query, :mutation] do
    [resolution]
  end
  defp policy_args(resolution) do
    [resolution, resolution.source]
  end
end
