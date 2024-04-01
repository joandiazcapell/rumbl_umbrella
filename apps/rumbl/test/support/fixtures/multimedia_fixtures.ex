defmodule Rumbl.MultimediaFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Rumbl.Multimedia` context.
  """
  alias Rumbl.Accounts
  alias Rumbl.Multimedia

  @doc """
  Generate a video.
  """
  def video_fixture(%Accounts.User{} = user, attrs \\ %{}) do
    category_id = Multimedia.get_by_a_Category!("Drama").id
    attrs =
      Enum.into(attrs, %{
        title: "A Title",
        url: "http://example.com",
        description: "a description",
        category_id: category_id
      })

    {:ok, video} = Multimedia.create_video(user, attrs)

    video
  end
end
