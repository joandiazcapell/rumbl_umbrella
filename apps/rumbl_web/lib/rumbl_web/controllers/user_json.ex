defmodule RumblWeb.UserJSON do

  alias Rumbl.Accounts.User

  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  def show(%{user: user}) do
    %{data: data(user)}
  end

  defp data(%User{} = user) do
    %{id: user.id, username: user.username}
  end
end
