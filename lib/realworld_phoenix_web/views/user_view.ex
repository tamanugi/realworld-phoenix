defmodule RealworldPhoenixWeb.UserView do
  use RealworldPhoenixWeb, :view
  alias RealworldPhoenixWeb.UserView

  def render("index.json", %{users: users}) do
    %{user: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user} = params) do
    %{user: render_one(user, UserView, "user.json", params)}
  end

  def render("user.json", %{user: user, token: token}) do
    render("user.json", %{user: user})
    |> Map.put_new(:token, token)
  end

  def render("user.json", %{user: user}) do
    %{
      email: user.email,
      username: user.username,
      bio: user.bio,
      image: user.image
    }
  end
end
