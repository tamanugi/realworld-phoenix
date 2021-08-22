defmodule RealworldPhoenixWeb.TagController do
  use RealworldPhoenixWeb, :controller

  alias RealworldPhoenix.Articles

  action_fallback RealworldPhoenixWeb.FallbackController

  def index(conn, _params) do
    conn
    |> render("index.json", tags: Articles.list_tags())
  end
end
