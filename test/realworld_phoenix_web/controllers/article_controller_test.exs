defmodule RealworldPhoenixWeb.ArticleControllerTest do
  use RealworldPhoenixWeb.ConnCase

  alias RealworldPhoenix.Articles
  alias RealworldPhoenix.Articles.Article
  alias RealworldPhoenix.Accounts

  @tag_candinates ~w(Elixir Rust Go Java Node Ruby)

  @create_attrs %{
    body: "some body",
    description: "some description",
    favoritesCount: 42,
    tagList: [],
    title: "some title"
  }
  @update_attrs %{
    body: "some updated body",
    description: "some updated description",
    favoritesCount: 43,
    tagList: [],
    title: "some updated title"
  }
  @invalid_attrs %{
    body: nil,
    description: nil,
    favoritesCount: nil,
    tagList: nil,
    title: nil
  }

  @valid_user_attrs %{
    username: "username",
    bio: "bio",
    image: "image",
    email: "email",
    password: "password"
  }

  def fixture(_kind, _attr \\ %{})

  def fixture(:article, attrs) do
    {:ok, article} =
      attrs
      |> Enum.into(@create_attrs)
      |> Articles.create_article()

    article
  end

  def fixture(:user, attrs) do
    {:ok, user} =
      attrs
      |> Enum.into(@valid_user_attrs)
      |> Accounts.create_user()

    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:login, :create_articles]

    test "lists all articles", %{conn: conn} do
      conn = get(conn, Routes.article_path(conn, :index))

      %{"articles" => articles, "articlesCount" => articleCount} = json_response(conn, 200)
      assert articles |> length() == length(@tag_candinates)
      assert articleCount == length(@tag_candinates)

      assert %{
               "author" => %{
                 "username" => "username",
                 "bio" => "bio",
                 "image" => "image",
                 "following" => _following
               },
               "body" => _,
               "description" => _,
               "slug" => _,
               "tagList" => [_],
               "title" => _,
               "createdAt" => _,
               "updatedAt" => _,
               "favorited" => false,
               "favoritesCount" => _
             } = List.first(articles)
    end

    test "filtering by tag", %{conn: conn} do
      conn = get(conn, Routes.article_path(conn, :index), tag: "Elixir")

      assert [
               %{
                 "tagList" => ["Elixir"]
               }
             ] = json_response(conn, 200)["articles"]
    end

    test "filtering by author", %{conn: conn} do
      user = fixture(:user, %{username: "hoge"})
      _ = fixture(:article, %{author_id: user.id})
      conn = get(conn, Routes.article_path(conn, :index), author: "hoge")

      assert [
               %{
                 "author" => %{"username" => "hoge"}
               }
             ] = json_response(conn, 200)["articles"]
    end
  end

  describe "create article" do
    setup [:login]

    test "renders article when data is valid", %{conn: conn} do
      conn = post(conn, Routes.article_path(conn, :create), article: @create_attrs)
      assert %{"slug" => id} = json_response(conn, 201)["article"]

      conn = get(conn, Routes.article_path(conn, :show, id))

      assert %{
               "body" => "some body",
               "description" => "some description",
               "slug" => "some-title",
               "tagList" => [],
               "title" => "some title"
             } = json_response(conn, 200)["article"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.article_path(conn, :create), article: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update article" do
    setup [:login, :create_article]

    test "renders article when data is valid", %{
      conn: conn,
      article: %Article{slug: id}
    } do
      conn = put(conn, Routes.article_path(conn, :update, id), article: @update_attrs)
      assert %{"slug" => id} = json_response(conn, 200)["article"]

      conn = get(conn, Routes.article_path(conn, :show, id))

      assert %{
               "body" => "some updated body",
               "description" => "some updated description",
               "slug" => "some-updated-title",
               "tagList" => [],
               "title" => "some updated title"
             } = json_response(conn, 200)["article"]
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      article: %Article{slug: id}
    } do
      conn = put(conn, Routes.article_path(conn, :update, id), article: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete article" do
    setup [:login, :create_article]

    test "deletes chosen article", %{conn: conn, article: %Article{slug: id}} do
      conn = delete(conn, Routes.article_path(conn, :delete, id))
      assert response(conn, 204)

      conn = get(conn, Routes.article_path(conn, :show, id))
      assert response(conn, 404)
    end
  end

  defp create_article(%{user: user}) do
    article = fixture(:article, %{author_id: user.id})
    %{article: article}
  end

  defp create_articles(%{user: user}) do
    @tag_candinates
    |> Enum.each(fn tag ->
      fixture(:article, %{tagList: [tag], author_id: user.id})
    end)
  end

  defp login(%{conn: conn}) do
    user = fixture(:user)
    %{conn: put_authorization(conn, user), user: user}
  end
end
