defmodule RealworldPhoenixWeb.ArticleControllerTest do
  use RealworldPhoenixWeb.ConnCase

  alias RealworldPhoenix.Articles
  alias RealworldPhoenix.Articles.Article

  @create_attrs %{
    body: "some body",
    description: "some description",
    favoritesCount: 42,
    id: "7488a646-e31f-11e4-aace-600308960662",
    slug: "some slug",
    tagList: [],
    title: "some title"
  }
  @update_attrs %{
    body: "some updated body",
    description: "some updated description",
    favoritesCount: 43,
    id: "7488a646-e31f-11e4-aace-600308960668",
    slug: "some updated slug",
    tagList: [],
    title: "some updated title"
  }
  @invalid_attrs %{body: nil, description: nil, favoritesCount: nil, id: nil, slug: nil, tagList: nil, title: nil}

  def fixture(:article) do
    {:ok, article} = Articles.create_article(@create_attrs)
    article
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all articles", %{conn: conn} do
      conn = get(conn, Routes.article_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create article" do
    test "renders article when data is valid", %{conn: conn} do
      conn = post(conn, Routes.article_path(conn, :create), article: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.article_path(conn, :show, id))

      assert %{
               "id" => id,
               "body" => "some body",
               "description" => "some description",
               "favoritesCount" => 42,
               "id" => "7488a646-e31f-11e4-aace-600308960662",
               "slug" => "some slug",
               "tagList" => [],
               "title" => "some title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.article_path(conn, :create), article: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update article" do
    setup [:create_article]

    test "renders article when data is valid", %{conn: conn, article: %Article{id: id} = article} do
      conn = put(conn, Routes.article_path(conn, :update, article), article: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.article_path(conn, :show, id))

      assert %{
               "id" => id,
               "body" => "some updated body",
               "description" => "some updated description",
               "favoritesCount" => 43,
               "id" => "7488a646-e31f-11e4-aace-600308960668",
               "slug" => "some updated slug",
               "tagList" => [],
               "title" => "some updated title"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, article: article} do
      conn = put(conn, Routes.article_path(conn, :update, article), article: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete article" do
    setup [:create_article]

    test "deletes chosen article", %{conn: conn, article: article} do
      conn = delete(conn, Routes.article_path(conn, :delete, article))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.article_path(conn, :show, article))
      end
    end
  end

  defp create_article(_) do
    article = fixture(:article)
    %{article: article}
  end
end
