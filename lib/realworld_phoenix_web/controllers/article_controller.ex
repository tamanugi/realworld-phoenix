defmodule RealworldPhoenixWeb.ArticleController do
  use RealworldPhoenixWeb, :controller

  alias RealworldPhoenix.Articles
  alias RealworldPhoenix.Articles.Article
  alias RealworldPhoenix.Repo

  action_fallback RealworldPhoenixWeb.FallbackController

  @default_limit 20
  @default_offset 0

  def index(conn, params) do
    keywords = for {key, val} <- params, do: {String.to_atom(key), val}

    keywords =
      case Guardian.Plug.current_resource(conn) do
        nil -> keywords
        user -> keywords |> Keyword.put(:user, user)
      end

    limit = keywords |> Keyword.get(:limit, @default_limit)
    offset = keywords |> Keyword.get(:offset, @default_offset)

    articles =
      Articles.list_articles(keywords, limit, offset)
      |> Repo.preload(:author)
      |> Repo.preload(:favorites)

    render(conn, "index.json", articles: articles)
  end

  def create(conn, %{"article" => article_params}) do
    with user <- Guardian.Plug.current_resource(conn),
         article_params <- Map.put(article_params, "author_id", user.id),
         {:ok, %Article{} = article} <- Articles.create_article(article_params) do
      article =
        article
        |> Repo.preload(:author)
        |> Repo.preload(:favorites)

      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.article_path(conn, :show, article))
      |> render("show.json", article: article)
    end
  end

  def show(conn, %{"slug" => slug}) do
    user = Guardian.Plug.current_resource(conn)

    article =
      Articles.get_article_by_slug!(slug, user)
      |> Repo.preload(:author)
      |> Repo.preload(:favorites)

    render(conn, "show.json", article: article)
  end

  def update(conn, %{"slug" => slug, "article" => article_params}) do
    article = Articles.get_article_by_slug!(slug)

    with {:ok, %Article{} = article} <- Articles.update_article(article, article_params) do
      article =
        article
        |> Repo.preload(:author)
        |> Repo.preload(:favorites)

      render(conn, "show.json", article: article)
    end
  end

  def delete(conn, %{"slug" => slug}) do
    article = Articles.get_article_by_slug!(slug)

    with {:ok, %Article{}} <- Articles.delete_article(article) do
      send_resp(conn, :no_content, "")
    end
  end

  def feed(conn, params) do
    limit = Map.get(params, "limit", @default_limit)
    offset = Map.get(params, "offset", @default_offset)

    user = Guardian.Plug.current_resource(conn)

    articles =
      Articles.list_articles_feed(user, limit, offset)
      |> Repo.preload(:author)
      |> Repo.preload(:favorites)

    render(conn, "index.json", articles: articles)
  end
end
