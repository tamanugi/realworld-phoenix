defmodule RealworldPhoenixWeb.CommentController do
  use RealworldPhoenixWeb, :controller

  alias RealworldPhoenix.Articles
  alias RealworldPhoenix.Articles.Article
  alias RealworldPhoenix.Articles.Comment
  alias RealworldPhoenix.Repo

  action_fallback RealworldPhoenixWeb.FallbackController

  def list(conn, %{"slug" => slug}) do
    user = Guardian.Plug.current_resource(conn)

    comments = Articles.list_comment_by_article_slug(slug, user) |> Repo.preload(:author)
    render(conn, "list.json", comments: comments)
  end

  def create(conn, %{"slug" => slug, "comment" => %{"body" => body}}) do
    with user <- Guardian.Plug.current_resource(conn),
         %Article{} = article <- Articles.get_article_by_slug(slug),
         {:ok, comment} = Articles.create_comment(%{body: body}, article, user) do
      render(conn, "show.json", comment: comment |> Repo.preload(:author))
    end
  end

  def delete(conn, %{"slug" => _, "id" => comment_id}) do
    %{id: user_id} = Guardian.Plug.current_resource(conn)

    with %Comment{} = comment <- Articles.get_comment!(comment_id),
         ^user_id <- comment.author_id,
         {:ok, _} <- Articles.delete_comment(comment) do
      send_resp(conn, 200, "")
    end
  end
end
