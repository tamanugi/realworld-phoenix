defmodule RealworldPhoenixWeb.ProfileView do
  use RealworldPhoenixWeb, :view
  alias RealworldPhoenixWeb.ProfileView

  def render("show.json", %{profile: profile, following: following}) do
    %{profile: render_one(profile, ProfileView, "profile.json", %{following: following})}
  end

  def render("profile.json", %{profile: profile, following: following}) do
    %{username: profile.username, bio: profile.bio, image: profile.image, following: following}
  end
end
