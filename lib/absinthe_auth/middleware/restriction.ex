defmodule AbsintheAuth.Middleware.Restriction do
  @behaviour Absinthe.Middleware

  alias Absinthe.Resolution
  alias AbsintheAuth.Permission

  def call(resolution, perms) do
    case check_permissions(resolution.source, perms, resolution) do
      true ->
        finish_auth(resolution)

      false ->
        resolution
        |> finish_auth
        |> Resolution.put_result({:error, "Denied"})
    end
  end

  defp check_permissions(object, permissions, resolution) do
    Enum.any?(permissions, &Permission.allow?(object, &1, resolution))
  end

  defp finish_auth(resolution) do
    %{resolution | context: Map.put(resolution.context, :authorisation, :done)}
  end
end
