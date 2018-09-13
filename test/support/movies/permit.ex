defmodule Movies.Policy.Permit do
  use AbsintheAuth.Policy
  alias Movies.Movie

  def producer(%{context: %{viewer_id: id}} = resolution, %Movie{producer_id: id}, _opts) do
    allow!(resolution)
  end
  def producer(resolution, _, _opts) do
    defer(resolution)
  end

  def studio_manager(%{context: %{viewer_id: "studio_manager"}} = resolution, _) do
    allow!(resolution)
  end
  def studio_manager(resolution, _) do
    defer(resolution)
  end
  def studio_manager(resolution, _, opts) do
    studio_manager(resolution, opts)
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
  def view(resolution, _obj, opts) do
    view(resolution, opts)
  end

  def create(%{context: %{viewer_id: "studio_manager"}} = resolution, _opts) do
    allow!(resolution)
  end
  def create(resolution, _) do
    deny!(resolution)
  end

  def released(resolution, %Movie{released: true}, _) do
    allow!(resolution)
  end
  def released(resolution, _, _) do
    defer(resolution)
  end
end
