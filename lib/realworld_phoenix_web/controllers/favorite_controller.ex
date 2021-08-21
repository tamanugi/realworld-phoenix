defmodule RealworldPhoenixWeb.FavoriteController do
  use RealworldPhoenixWeb, :controller

  alias RealworldPhoenix.Articles
  alias RealworldPhoenix.Repo
  alias RealworldPhoenix.Articles.Favorite
  alias RealworldPhoenix.Articles.Article

  action_fallback RealworldPhoenixWeb.FallbackController

  def create(conn, %{"slug" => slug}) do
    with user <- Guardian.Plug.current_resource(conn),
         %Article{} = article <- Articles.get_article_by_slug(slug),
         {:ok, %Favorite{}} <- Articles.create_favorite(user, article) do
      # refech article data
      article =
        Articles.get_article_by_slug(slug, user)
        |> Repo.preload(:author)
        |> Repo.preload(:favorites)

      conn
      |> put_status(:created)
      |> render("show.json", article: article)
    end
  end

  def delete(conn, %{"slug" => slug}) do
    with user <- Guardian.Plug.current_resource(conn),
         %Article{} = article <-
           Articles.get_article_by_slug(slug, user)
           |> Repo.preload(:author)
           |> Repo.preload(:favorites),
         {1, _} <- Articles.delete_favorite(user, article) |> IO.inspect() do
      conn
      |> render("show.json",
        article:
          article
          |> Map.update!(:favorited, fn _ -> false end)
      )
    end
  end
end
