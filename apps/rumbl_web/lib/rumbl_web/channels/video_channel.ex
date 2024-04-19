defmodule RumblWeb.VideoChannel do
  #use RumblWeb, :verified_routes
  use RumblWeb, :channel

  alias Rumbl.Multimedia
  alias Rumbl.Accounts

  @impl true
  def join("videos:" <> video_id, payload, socket) do
    send(self(), :after_join)
    last_seen_id = payload["last_seen_id"] || 0
    video_id = String.to_integer(video_id)
    video = Multimedia.get_video!(video_id)

    annotations =
      video
      |> Multimedia.list_anotations(last_seen_id)

    annotations_json = RumblWeb.AnnotationJSON.index(%{annotations: annotations})
    #annotations = ~p"/api/annotations/#{video_id}"

    {:ok, %{annotations: annotations_json}, assign(socket, :video_id, video_id)}
  end

  @impl true
  def handle_info(:after_join, socket) do
    push(socket, "presence_state", RumblWeb.Presence.list(socket))
    {:ok, _} = RumblWeb.Presence.track(socket, socket.assigns.user_id, %{device: "browser"})
    {:noreply, socket}
  end

  @impl true
  def handle_in(event, payload, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    handle_in(event, payload, user, socket)
  end

  def handle_in("new_annotation", payload, user, socket) do
    case Multimedia.annotate_video(user, socket.assigns.video_id, payload) do
      {:ok, annotation} ->
        broadcat_annotation(socket, user, annotation)
        Task.start(fn -> compute_additional_info(annotation, socket) end)
        {:reply, :ok, socket}
      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  defp compute_additional_info(annotation, socket) do
    InfoSys.compute(annotation.body, limit: 1, timeout: 10_000) #TODO I have to create to calls here don't know why otherwise it doesn't work
    for result <- InfoSys.compute(annotation.body, limit: 1, timeout: 10_000) do
      backend_user = Accounts.get_user_by(username: result.backend.name())
      attrs = %{body: result.text, at: annotation.at}

      case Multimedia.annotate_video(backend_user, annotation.video_id, attrs) do
        {:ok, info_ann} -> broadcat_annotation(socket, backend_user, info_ann)
        {:error, _changeset} -> :ignore
      end
    end
  end

  defp broadcat_annotation(socket, user, annotation) do
    broadcast!(socket, "new_annotation", %{
      id: annotation.id,
      user: RumblWeb.UserJSON.show(%{user: user}),
      body: annotation.body,
      at: annotation.at
    })
  end
end
