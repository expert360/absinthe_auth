defmodule AbsintheAuthTest.SetupHelpers do
  def viewer_is_producer(_) do
    %{context: %{viewer_id: 1}}
  end
end
