defmodule RumblWeb.AnnotationControllerTest do
  use RumblWeb.ConnCase

  import Rumbl.MultimediaFixtures
  import Rumbl.AccountFixtures

  @video_attrs %{url: "http://youtu.be", title: "vid", description: "a vid"}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all annotations", %{conn: conn} do
      owner = user_fixture(username: "owner")
      video = video_fixture(owner, @video_attrs)

      conn = get(conn, ~p"/api/annotations/#{video.id}")
      assert json_response(conn, 200)["data"] == []
    end
  end

end
