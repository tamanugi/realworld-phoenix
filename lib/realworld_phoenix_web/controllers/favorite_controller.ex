defmodule RealworldPhoenixWeb.FavoriteController do
  use RealworldPhoenixWeb, :controller

  alias RealworldPhoenix.Articles
  alias RealworldPhoenix.Articles.Favorite
  alias RealworldPhoenix.Articles.Article

  action_fallback RealworldPhoenixWeb.FallbackController

  def create(conn, %{"slug" => slug}) do
    with user <- Guardian.Plug.current_resource(conn),
         %Article{} = article <- Articles.get_article_by_slug!(slug),
         {:ok, %Favorite{} = favorite} <- Articles.create_favorite(user, article) do
      conn
      |> put_status(:created)
      |> render("show.json", favorite: favorite)
    end
  end

  def delete(conn, %{"slug" => slug}) do
    user = Guardian.Plug.current_resource(conn)
    article = Articles.get_article_by_slug!(slug)

    with {1, _} <- Articles.delete_favorite(user, article) do
      send_resp(conn, :no_content, "")
    end
  end
end
