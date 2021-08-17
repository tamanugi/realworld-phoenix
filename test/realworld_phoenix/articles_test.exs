defmodule RealworldPhoenix.ArticlesTest do
  use RealworldPhoenix.DataCase

  alias RealworldPhoenix.Articles
  alias RealworldPhoenix.Repo
  alias RealworldPhoenix.Accounts
  alias RealworldPhoenix.Articles.Comment

  describe "articles" do
    alias RealworldPhoenix.Articles.Article

    @valid_user %{
      username: "author",
      email: "email",
      bio: "bio",
      password: "hoge",
      image: "image_url"
    }

    @valid_attrs %{
      body: "some body",
      description: "some description",
      favoritesCount: 42,
      slug: "some slug",
      tagList: [],
      title: "some title",
      author: @valid_user
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
      username: "hoge",
      password: "hoge",
      email: "email",
      bio: "bio",
      image: "image"
    }

    def article_fixture(attrs \\ %{}) do
      {:ok, article} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Articles.create_article()

      article |> Repo.preload(:author)
    end

    def user_fixture(attrs \\ %{}) do
      {:ok, author} =
        attrs
        |> Enum.into(@valid_user_attrs)
        |> Accounts.create_user()

      author
    end

    def comment_fixture(attrs \\ %{body: "some body"}) do
      {:ok, comment} =
        attrs
        |> Articles.create_comment(article_fixture(), user_fixture())

      comment
    end

    test "list_articles/0 returns all articles" do
      article = article_fixture()
      assert is_list(Articles.list_articles())
    end

    test "get_article!/1 returns the article with given id" do
      article = article_fixture()
      assert %Article{} = Articles.get_article!(article.id)
    end

    test "create_article/1 with valid data creates a article" do
      assert {:ok, %Article{} = article} = Articles.create_article(@valid_attrs)
      assert article.body == "some body"
      assert article.description == "some description"
      assert article.favoritesCount == 42
      assert article.slug == "some slug"
      assert article.tagList == []
      assert article.title == "some title"
    end

    test "create_article/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Articles.create_article(@invalid_attrs)
    end

    test "update_article/2 with valid data updates the article" do
      article = article_fixture()
      assert {:ok, %Article{} = article} = Articles.update_article(article, @update_attrs)
      assert article.body == "some updated body"
      assert article.description == "some updated description"
      assert article.favoritesCount == 43
      assert article.slug == "some updated slug"
      assert article.tagList == []
      assert article.title == "some updated title"
    end

    test "update_article/2 with invalid data returns error changeset" do
      article = article_fixture()
      assert {:error, %Ecto.Changeset{}} = Articles.update_article(article, @invalid_attrs)
    end

    test "delete_article/1 deletes the article" do
      article = article_fixture()
      assert {:ok, %Article{}} = Articles.delete_article(article)
      assert_raise Ecto.NoResultsError, fn -> Articles.get_article!(article.id) end
    end

    test "change_article/1 returns a article changeset" do
      article = article_fixture()
      assert %Ecto.Changeset{} = Articles.change_article(article)
    end

    test "create_comment/1 with valid data" do
      article = article_fixture()
      author = user_fixture()

      assert {:ok, comment} = Articles.create_comment(%{body: "test comment"}, article, author)
      assert %Comment{id: _, body: "test comment", inserted_at: _, updated_at: _} = comment
    end

    test "delete_comment/1 with valid data" do
      comment = comment_fixture()

      assert {:ok, %Comment{}} = Articles.delete_comment(comment)
    end
  end

  describe "favorites" do
    alias RealworldPhoenix.Articles.Favorite

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def favorite_fixture(attrs \\ %{}) do
      {:ok, favorite} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Articles.create_favorite()

      favorite
    end

    test "list_favorites/0 returns all favorites" do
      favorite = favorite_fixture()
      assert Articles.list_favorites() == [favorite]
    end

    test "get_favorite!/1 returns the favorite with given id" do
      favorite = favorite_fixture()
      assert Articles.get_favorite!(favorite.id) == favorite
    end

    test "create_favorite/1 with valid data creates a favorite" do
      assert {:ok, %Favorite{} = favorite} = Articles.create_favorite(@valid_attrs)
    end

    test "create_favorite/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Articles.create_favorite(@invalid_attrs)
    end

    test "update_favorite/2 with valid data updates the favorite" do
      favorite = favorite_fixture()
      assert {:ok, %Favorite{} = favorite} = Articles.update_favorite(favorite, @update_attrs)
    end

    test "update_favorite/2 with invalid data returns error changeset" do
      favorite = favorite_fixture()
      assert {:error, %Ecto.Changeset{}} = Articles.update_favorite(favorite, @invalid_attrs)
      assert favorite == Articles.get_favorite!(favorite.id)
    end

    test "delete_favorite/1 deletes the favorite" do
      favorite = favorite_fixture()
      assert {:ok, %Favorite{}} = Articles.delete_favorite(favorite)
      assert_raise Ecto.NoResultsError, fn -> Articles.get_favorite!(favorite.id) end
    end

    test "change_favorite/1 returns a favorite changeset" do
      favorite = favorite_fixture()
      assert %Ecto.Changeset{} = Articles.change_favorite(favorite)
    end
  end
end
