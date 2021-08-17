defmodule RealworldPhoenixWeb.CommentControllerTest do
  use RealworldPhoenixWeb.ConnCase

  alias RealworldPhoenix.Articles
  alias RealworldPhoenix.Profiles
  alias RealworldPhoenix.Accounts

  @valid_attrs %{
    body: "some body"
  }

  @article_attrs %{
    body: "some body",
    description: "some description",
    favoritesCount: 42,
    slug: "some slug",
    tagList: [],
    title: "some title"
  }

  @user_attrs %{
    username: "username",
    bio: "bio",
    image: "image",
    email: "email",
    password: "password"
  }

  def fixture(a, b \\ %{})

  def fixture(:article, attr) do
    {:ok, article} =
      attr
      |> Enum.into(@article_attrs)
      |> Articles.create_article()

    article
  end

  def fixture(:user, attr) do
    {:ok, user} =
      attr
      |> Enum.into(@user_attrs)
      |> Accounts.create_user()

    user
  end

  def fixture(:comment, attr) do
    {:ok, comment} =
      attr
      |> Enum.into(%{body: "some body"})
      |> Articles.create_comment()

    comment
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:login, :create_article, :create_comment_other_user]

    test "multiple comments by article", %{conn: conn, article: article} do
      conn = get(conn, Routes.comment_path(conn, :list, article.slug))

      assert [
               %{
                 "author" => %{
                   "bio" => "bio",
                   "following" => true,
                   "image" => "image",
                   "username" => "username"
                 },
                 "body" => "some body",
                 "createdAt" => _,
                 "id" => _,
                 "updatedAt" => _
               }
             ] = json_response(conn, 200)["comments"]
    end
  end

  describe "create" do
    setup [:login, :create_article]

    test "crate comment", %{conn: conn, article: article} do
      conn = post(conn, Routes.comment_path(conn, :create, article.slug), comment: @valid_attrs)

      assert %{
               "author" => %{
                 "bio" => _,
                 "following" => false,
                 "image" => _,
                 "username" => _
               },
               "body" => "some body",
               "createdAt" => _,
               "id" => _,
               "updatedAt" => _
             } = json_response(conn, 200)["comment"]
    end
  end

  describe "delete" do
    setup [:login, :create_article, :create_comment]

    test "delete comment", %{conn: conn, article: article, comment: comment} do
      conn = delete(conn, Routes.comment_path(conn, :delete, article.slug, comment.id))
      assert response(conn, 200)

      conn = get(conn, Routes.comment_path(conn, :list, article.slug))
      assert [] == json_response(conn, 200)["comments"]
    end
  end

  defp create_article(%{user: user}) do
    article = fixture(:article, %{author_id: user.id})
    %{article: article}
  end

  defp login(%{conn: conn}) do
    user = fixture(:user)
    %{conn: put_authorization(conn, user), user: user}
  end

  defp create_comment(%{article: article, user: user}) do
    comment = fixture(:comment, %{article_id: article.id, author_id: user.id})

    %{comment: comment}
  end

  defp create_comment_other_user(%{article: article, user: user}) do
    comment_user = fixture(:user)
    comment = fixture(:comment, %{article_id: article.id, author_id: comment_user.id})
    Profiles.create_follow(user, comment_user)

    %{comment: comment}
  end
end
