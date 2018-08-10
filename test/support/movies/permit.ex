defmodule Movies.Policy.Permit do
  use AbsintheAuth.Policy
  alias Movies.Movie

  def view(%{context: %{viewer_id: "producer"}} = resolution, %Movie{id: 1}, _opts) do
    allow!(resolution)
  end

  def view(%{context: %{viewer_id: "studio_manager"}} = resolution, %Movie{}, _opts) do
    allow!(resolution)
  end

  def _view(%{context: %{viewer_id: "producer"}} = resolution, _, _) do
  

    IO.inspect(arg(resolution, :id), label: "AAAA")
    deny!(resolution)
  end

  def view(resolution, _, _) do
    deny!(resolution)
  end

  def create(%{context: %{viewer_id: "studio_manager"}} = resolution, _, _opts) do
    if is_mutation?(resolution) do
      allow!(resolution)
    else
      defer(resolution)
    end
  end

  def create(resolution, _, _) do
    deny!(resolution)
  end
end
