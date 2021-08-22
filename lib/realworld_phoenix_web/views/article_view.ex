defmodule RealworldPhoenixWeb.ArticleView do
  use RealworldPhoenixWeb, :view
  alias RealworldPhoenixWeb.ArticleView

  alias RealworldPhoenixWeb.TagView

  def render("index.json", %{articles: articles}) do
    %{
      articles: render_many(articles, ArticleView, "article.json"),
      articlesCount: length(articles)
    }
  end

  def render("show.json", %{article: article}) do
    %{article: render_one(article, ArticleView, "article.json")}
  end

  def render("article.json", %{article: article}) do
    %{
      slug: article.slug,
      title: article.title,
      description: article.description,
      body: article.body,
      tagList: render_many(article.tagList, TagView, "tag.json"),
      favoritesCount: article.favorites |> Enum.count(),
      favorited: article.favorited,
      createdAt:
        article.inserted_at
        |> DateTime.truncate(:millisecond)
        |> DateTime.to_iso8601(:extended, 0),
      updatedAt:
        article.updated_at
        |> DateTime.truncate(:millisecond)
        |> DateTime.to_iso8601(:extended, 0),
      author: render_one(article.author, ArticleView, "author.json")
    }
  end

  def render("author.json", %{article: author}) do
    %{
      username: author.username,
      bio: author.bio,
      image: author.image,
      following: author.following
    }
  end
end
