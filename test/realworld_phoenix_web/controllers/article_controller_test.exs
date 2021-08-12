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
    slug: "some slug",
    tagList: [],
    title: "some title"
  }
  @update_attrs %{
    body: "some updated body",
    description: "some updated description",
    favoritesCount: 43,
    slug: "some updated slug",
    tagList: [],
    title: "some updated title"
  }
  @invalid_attrs %{
    body: nil,
    description: nil,
    favoritesCount: nil,
    slug: nil,
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

  def fixture(:article, authorId, tags \\ []) do
    {:ok, article} =
      Map.update!(@create_attrs, :tagList, fn _ -> tags end)
      |> Map.put(:author_id, authorId)
      |> Articles.create_article()

    article
  end

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@valid_user_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:login, :create_articles]

    test "lists all articles", %{conn: conn} do
      conn = get(conn, Routes.article_path(conn, :index))

      %{"articles" => articles, "articleCount" => articleCount} = json_response(conn, 200)
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
               "favoritesCount" => _,
               "slug" => _,
               "tagList" => [_],
               "title" => _
             } = articles |> List.first()
    end

    test "filtering by tag", %{conn: conn} do
      conn = get(conn, Routes.article_path(conn, :index), tag: "Elixir")

      assert [
               %{
                 "tagList" => ["Elixir"]
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
               "favoritesCount" => 42,
               "slug" => "some slug",
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
      article: %Article{slug: id} = article
    } do
      conn = put(conn, Routes.article_path(conn, :update, id), article: @update_attrs)
      assert %{"slug" => id} = json_response(conn, 200)["article"]

      conn = get(conn, Routes.article_path(conn, :show, id))

      assert %{
               "body" => "some updated body",
               "description" => "some updated description",
               "favoritesCount" => 43,
               "slug" => "some updated slug",
               "tagList" => [],
               "title" => "some updated title"
             } = json_response(conn, 200)["article"]
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      article: %Article{slug: id} = article
    } do
      conn = put(conn, Routes.article_path(conn, :update, id), article: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete article" do
    setup [:login, :create_article]

    test "deletes chosen article", %{conn: conn, article: %Article{slug: id} = article} do
      conn = delete(conn, Routes.article_path(conn, :delete, id))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.article_path(conn, :show, id))
      end
    end
  end

  defp create_article(%{user: user}) do
    article = fixture(:article, user.id)
    %{article: article}
  end

  defp create_articles(%{user: user}) do
    @tag_candinates
    |> Enum.each(fn tag ->
      fixture(:article, user.id, [tag])
    end)
  end

  defp login(%{conn: conn}) do
    user = fixture(:user)
    %{conn: put_authorization(conn, user), user: user}
  end
end
