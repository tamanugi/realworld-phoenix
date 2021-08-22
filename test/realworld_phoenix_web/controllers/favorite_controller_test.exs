defmodule RealworldPhoenixWeb.FavoriteControllerTest do
  use RealworldPhoenixWeb.ConnCase

  alias RealworldPhoenix.Accounts
  alias RealworldPhoenix.Accounts.User
  alias RealworldPhoenix.Articles
  alias RealworldPhoenix.Articles.Article

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

  def fixture(:favorite, %User{} = user, %Article{} = article) do
    {:ok, favorite} = Articles.create_favorite(user, article)
    favorite
  end

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

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create favorite" do
    setup [:login, :create_article]

    test "renders favorite when data is valid", %{conn: conn, article: article} do
      conn = post(conn, Routes.favorite_path(conn, :create, article.slug))
      expected_slug = article.slug
      assert %{"slug" => ^expected_slug} = json_response(conn, 201)["article"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.favorite_path(conn, :create, "hogehoge"))
      assert response(conn, 404)
    end
  end

  describe "delete favorite" do
    setup [:login, :create_article, :create_favorite]

    test "deletes chosen favorite", %{conn: conn, article: article} do
      conn = delete(conn, Routes.favorite_path(conn, :delete, article.slug))
      assert response(conn, 200)
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

  defp create_favorite(%{user: user, article: article}) do
    favorite = fixture(:favorite, user, article)
    %{favorite: favorite}
  end
end
