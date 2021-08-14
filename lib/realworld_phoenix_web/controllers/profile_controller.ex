defmodule RealworldPhoenixWeb.ProfileController do
  use RealworldPhoenixWeb, :controller

  alias RealworldPhoenix.Profiles

  action_fallback RealworldPhoenixWeb.FallbackController

  def show(conn, %{"username" => username}) do
    profile = Profiles.get_by_username(username)
    render(conn, "show.json", profile: profile)
  end
end
