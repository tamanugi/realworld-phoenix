defmodule RealworldPhoenixWeb.CommentView do
  use RealworldPhoenixWeb, :view
  alias RealworldPhoenixWeb.CommentView

  alias RealworldPhoenix.Accounts.User
  alias RealworldPhoenix.Articles.Comment

  def render("list.json", %{comments: comments}) do
    %{comments: render_many(comments, CommentView, "comment.json")}
  end

  def render("show.json", %{comment: comment}) do
    %{comment: render_one(comment, CommentView, "comment.json")}
  end

  def render("comment.json", %{comment: %Comment{} = comment}) do
    %{
      id: comment.id,
      createdAt:
        comment.inserted_at
        |> DateTime.truncate(:millisecond)
        |> DateTime.to_iso8601(:extended, 0),
      updatedAt:
        comment.updated_at
        |> DateTime.truncate(:millisecond)
        |> DateTime.to_iso8601(:extended, 0),
      body: comment.body,
      author: render_one(comment.author, CommentView, "author.json", as: :author)
    }
  end

  def render("author.json", %{author: %User{} = author}) do
    %{
      username: author.username,
      bio: author.bio,
      image: author.image,
      following:
        case author.following do
          nil -> false
          following -> following
        end
    }
  end
end
