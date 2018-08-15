defmodule Movies.Policy.Permit do
  use AbsintheAuth.Policy
  alias Movies.Movie

  def budget(%{context: %{viewer_id: "producer"}} = resolution, %Movie{id: 1}, _opts) do
    allow!(resolution)
  end
  def budget(%{context: %{viewer_id: "studio_manager"}} = resolution, %Movie{}, _opts) do
    allow!(resolution)
  end
  def budget(resolution, _, _) do
    deny!(resolution)
  end

  # TODO: Create a test that allows us to check args - maybe in the create? (multiple studios?)
  def _view(%{context: %{viewer_id: "producer"}} = resolution, _, _) do
    if arg(resolution, :id) == "1" do
      allow!(resolution)
    else
      deny!(resolution)
    end
  end

  def view(resolution, _) do
    allow!(resolution)
  end
  def view(resolution, _obj, _) do
    allow!(resolution)
  end

  def create(%{context: %{viewer_id: "studio_manager"}} = resolution, _opts) do
    allow!(resolution)
  end
  def create(resolution, _) do
    deny!(resolution)
  end
end
