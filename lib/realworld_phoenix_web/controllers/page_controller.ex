defmodule RealworldPhoenixWeb.PageController do
  use RealworldPhoenixWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
