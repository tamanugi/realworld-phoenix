defmodule RealworldPhoenixWeb.ArticleController do
  use RealworldPhoenixWeb, :controller

  alias RealworldPhoenix.Articles
  alias RealworldPhoenix.Articles.Article

  action_fallback RealworldPhoenixWeb.FallbackController

  def index(conn, params) do
    keywords = for {key, val} <- params, do: {String.to_atom(key), val}

    keywords =
      case Guardian.Plug.current_resource(conn) do
        nil -> keywords
        user -> keywords |> Keyword.put(:user, user)
      end

    articles =
      Articles.list_articles(keywords)
      |> Articles.article_preload()

    render(conn, "index.json", articles: articles)
  end

  def create(conn, %{"article" => article_params}) do
    with user <- Guardian.Plug.current_resource(conn),
         article_params <- Map.put(article_params, "author_id", user.id),
         {:ok, %Article{} = article} <- Articles.create_article(article_params) do
      article =
        article
        |> Articles.article_preload()

      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.article_path(conn, :show, article))
      |> render("show.json", article: article)
    end
  end

  def show(conn, %{"slug" => slug}) do
    user = Guardian.Plug.current_resource(conn)

    with %Article{} = article <-
           Articles.get_article_by_slug(slug, user),
         article <- article |> Articles.article_preload() do
      render(conn, "show.json", article: article)
    end
  end

  def update(conn, %{"slug" => slug, "article" => article_params}) do
    with article <- Articles.get_article_by_slug(slug),
         {:ok, %Article{} = article} <- Articles.update_article(article, article_params) do
      article =
        article
        |> Articles.article_preload()

      render(conn, "show.json", article: article)
    end
  end

  def delete(conn, %{"slug" => slug}) do
    with article <- Articles.get_article_by_slug(slug),
         {:ok, %Article{}} <- Articles.delete_article(article) do
      send_resp(conn, :no_content, "")
    end
  end

  def feed(conn, params) do
    keywords = for {key, val} <- params, do: {String.to_atom(key), val}

    user = Guardian.Plug.current_resource(conn)

    articles =
      Articles.list_articles_feed(user, keywords)
      |> Articles.article_preload()

    render(conn, "index.json", articles: articles)
  end
end
