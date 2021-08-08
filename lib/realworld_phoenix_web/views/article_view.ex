defmodule RealworldPhoenixWeb.ArticleView do
  use RealworldPhoenixWeb, :view
  alias RealworldPhoenixWeb.ArticleView

  def render("index.json", %{articles: articles}) do
    %{articles: render_many(articles, ArticleView, "article.json")}
  end

  def render("show.json", %{article: article}) do
    %{data: render_one(article, ArticleView, "article.json")}
  end

  def render("article.json", %{article: article}) do
    %{
      slug: article.slug,
      title: article.title,
      description: article.description,
      body: article.body,
      tagList: article.tagList,
      favoritesCount: article.favoritesCount
    }
  end
end
