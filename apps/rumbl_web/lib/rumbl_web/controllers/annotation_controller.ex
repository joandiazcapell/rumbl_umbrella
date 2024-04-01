defmodule RumblWeb.AnnotationController do
  use RumblWeb, :controller

  alias Rumbl.Multimedia
  #alias Rumbl.Multimedia.Annotation

  action_fallback RumblWeb.FallbackController

  def index(conn, %{"id" => video_id}) do
    annotations = Multimedia.get_video!(video_id)
    |> Multimedia.list_anotations()

    render(conn, :index, annotations: annotations)
  end

  #def create(conn, %{"annotation" => annotation_params}) do
  #  with {:ok, %Annotation{} = annotation} <- Multimedia.create_annotation(annotation_params) do
  #    conn
  #    |> put_status(:created)
  #    |> put_resp_header("location", ~p"/api/annotations/#{annotation}")
  #    |> render(:show, annotation: annotation)
  #  end
  #end

  #def show(conn, %{"id" => id}) do
  #  annotation = Multimedia.get_annotation!(id)
  #  render(conn, :show, annotation: annotation)
  #end

  #def update(conn, %{"id" => id, "annotation" => annotation_params}) do
  #  annotation = Multimedia.get_annotation!(id)

  #  with {:ok, %Annotation{} = annotation} <- Multimedia.update_annotation(annotation, annotation_params) do
  #    render(conn, :show, annotation: annotation)
  #  end
  #end

  #def delete(conn, %{"id" => id}) do
  #  annotation = Multimedia.get_annotation!(id)

  #  with {:ok, %Annotation{}} <- Multimedia.delete_annotation(annotation) do
  #    send_resp(conn, :no_content, "")
  #  end
  #end
end
