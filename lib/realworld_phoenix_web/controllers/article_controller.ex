defmodule RealworldPhoenixWeb.ArticleController do
  use RealworldPhoenixWeb, :controller

  alias RealworldPhoenix.Articles
  alias RealworldPhoenix.Articles.Article
  alias RealworldPhoenix.Repo

  action_fallback RealworldPhoenixWeb.FallbackController

  def index(conn, params) do
    keywords = for {key, val} <- params, do: {String.to_atom(key), val}
    articles = Articles.list_articles(keywords) |> Repo.preload(:author)
    render(conn, "index.json", articles: articles)
  end

  def create(conn, %{"article" => article_params}) do
    with user <- Guardian.Plug.current_resource(conn),
         article_params <- Map.put(article_params, "author_id", user.id),
         {:ok, %Article{} = article} <- Articles.create_article(article_params) do
      article = article |> Repo.preload(:author)

      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.article_path(conn, :show, article))
      |> render("show.json", article: article)
    end
  end

  def show(conn, %{"slug" => slug}) do
    article = Articles.get_article_by_slug!(slug) |> Repo.preload(:author)
    render(conn, "show.json", article: article)
  end

  def update(conn, %{"slug" => slug, "article" => article_params}) do
    article = Articles.get_article_by_slug!(slug)

    with {:ok, %Article{} = article} <- Articles.update_article(article, article_params) do
      article = article |> Repo.preload(:author)
      render(conn, "show.json", article: article)
    end
  end

  def delete(conn, %{"slug" => slug}) do
    article = Articles.get_article_by_slug!(slug)

    with {:ok, %Article{}} <- Articles.delete_article(article) do
      send_resp(conn, :no_content, "")
    end
  end
end
