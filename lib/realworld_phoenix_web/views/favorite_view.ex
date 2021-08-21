defmodule RealworldPhoenixWeb.FavoriteView do
  use RealworldPhoenixWeb, :view

  alias RealworldPhoenixWeb.ArticleView

  def render("show.json", params) do
    ArticleView.render("show.json", params)
  end
end
