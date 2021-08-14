defmodule RealworldPhoenixWeb.ProfileView do
  use RealworldPhoenixWeb, :view
  alias RealworldPhoenixWeb.ProfileView

  def render("show.json", %{profile: profile}) do
    %{profile: render_one(profile, ProfileView, "profile.json")}
  end

  def render("profile.json", %{profile: profile}) do
    %{username: profile.username, bio: profile.bio, image: profile.image}
  end
end
