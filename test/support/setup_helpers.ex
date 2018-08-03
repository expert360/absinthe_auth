defmodule AbsintheAuthTest.SetupHelpers do
  def viewer_is_producer(_) do
    %{context: %{viewer_id: "producer"}}
  end

  def viewer_is_studio_manager(_) do
    %{context: %{viewer_id: "studio_manager"}}
  end
end
