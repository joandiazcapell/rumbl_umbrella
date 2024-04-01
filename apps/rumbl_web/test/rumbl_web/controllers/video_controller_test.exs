defmodule RumblWeb.VideoControllerTestuse do
  use RumblWeb.ConnCase, async: true

  import Rumbl.MultimediaFixtures
  import Rumbl.AccountFixtures
  alias Rumbl.Multimedia

  @create_attrs %{url: "http://youtu.be", title: "vid", description: "a vid"}
  @invalid_attrs %{title: "invalid"}

  defp video_count, do: Enum.count(Multimedia.list_videos())

  describe "with a logged-in user" do
    #setup [:add_login]
    setup %{conn: conn, login_as: username} do
      user = user_fixture(username: username)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    @tag login_as: "fulanito"
    test "list all user's videos on index", %{conn: conn, user: user} do
      user_video = video_fixture(user, title: "funny cats")
      other_video = video_fixture(user_fixture(username: "other"), title: "another video")

      conn = get(conn, ~p"/manage/videos")
      assert html_response(conn, 200) =~ "Listing Videos"
      assert String.contains?(conn.resp_body, user_video.title)
      refute String.contains?(conn.resp_body, other_video.title)
    end

    @tag login_as: "fulanito"
    test "creates user video and redirects", %{conn: conn, user: user} do
      new_attrs = Map.put(@create_attrs, :category_id, Multimedia.get_by_a_Category!("Drama").id)

      creates_conn = post(conn, ~p"/manage/videos/", video: new_attrs)

      assert %{id: id} = redirected_params(creates_conn)
      assert redirected_to(creates_conn) == ~p"/manage/videos/#{id}"

      conn = get(conn, ~p"/manage/videos/#{id}")
      assert html_response(conn, 200) =~ "Video #{id}"

      assert Multimedia.get_video!(id).user_id == user.id
    end

    @tag login_as: "fulanito"
    test "does not create vid, renders errors when invalid", %{conn: conn} do
      count_before = video_count()
      conn =
        post(conn,~p"/manage/videos", video: @invalid_attrs)
        assert html_response(conn, 200) =~ "check the errors"
        assert video_count() == count_before
    end
  end

  test "requires user authentication on all actions", %{conn: conn} do

    Enum.each([
      get(conn, ~p"/manage/videos/new"),
      get(conn, ~p"/manage/videos/index"),
      get(conn, ~p"/manage/videos/123"),
      get(conn, ~p"/manage/videos/123/edit"),
      put(conn, ~p"/manage/videos/123"),
      post(conn, ~p"/manage/videos"),
      delete(conn, ~p"/manage/videos/123"),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end
    )
  end

  test "authorizes action against access by other users", %{conn: conn} do
    owner = user_fixture(username: "owner")
    video = video_fixture(owner, @create_attrs)
    non_owner = user_fixture(username: "sneaky")
    conn = assign(conn, :current_user, non_owner)

    assert_error_sent :not_found, fn -> get(conn, ~p"/manage/videos/#{video.id}") end
    assert_error_sent :not_found, fn -> get(conn, ~p"/manage/videos/#{video.id}/edit") end
    assert_error_sent :not_found, fn -> put(conn, ~p"/manage/videos/#{video.id}", video: @create_attrs) end
    assert_error_sent :not_found, fn -> delete(conn, ~p"/manage/videos/#{video.id}") end
  end

  #With a function from the setup
  #defp add_login (%{conn: conn}) do
  #  user = user_fixture()
  #  conn = assign(conn, :current_user, user)
  #
  # {:ok, conn: conn, user: user}
  #end

end
