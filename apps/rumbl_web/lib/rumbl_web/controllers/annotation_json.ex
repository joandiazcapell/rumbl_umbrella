defmodule RumblWeb.AnnotationJSON do
  alias Rumbl.Multimedia.Annotation

  @doc """
  Renders a list of annotations.
  """
  def index(%{annotations: annotations}) do
    %{data: for(annotation <- annotations, do: data(annotation))}
  end

  @doc """
  Renders a single annotation.
  """
  def show(%{annotation: annotation}) do
    %{data: data(annotation)}
  end

  defp data(%Annotation{} = annotation) do
    %{
      id: annotation.id,
      at: annotation.at,
      body: annotation.body,
      user: RumblWeb.UserJSON.show(%{user: annotation.user})
    }
  end
end
