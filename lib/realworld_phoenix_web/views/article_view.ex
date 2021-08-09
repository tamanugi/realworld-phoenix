defmodule RealworldPhoenixWeb.ArticleView do
  use RealworldPhoenixWeb, :view
  alias RealworldPhoenixWeb.ArticleView

  alias RealworldPhoenix.Repo

  def render("index.json", %{articles: articles}) do
    %{articles: render_many(articles, ArticleView, "article.json")}
  end

  def render("show.json", %{article: article}) do
    %{article: render_one(article, ArticleView, "article.json")}
  end

  def render("article.json", %{article: article}) do
    # Anti Pattern?
    article = Repo.preload(article, :author)

    %{
      slug: article.slug,
      title: article.title,
      description: article.description,
      body: article.body,
      tagList: article.tagList,
      favoritesCount: article.favoritesCount,
      author: render_one(article.author, ArticleView, "author.json")
    }
  end

  def render("author.json", %{article: author}) do
    %{
      username: author.username,
      bio: author.bio,
      image: author.image
      # "following": false
    }
  end
end
