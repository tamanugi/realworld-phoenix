defmodule RealworldPhoenixWeb.UserView do
  use RealworldPhoenixWeb, :view
  alias RealworldPhoenixWeb.UserView

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
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
