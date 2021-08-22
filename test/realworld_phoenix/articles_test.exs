defmodule RealworldPhoenix.ArticlesTest do
  use RealworldPhoenix.DataCase

  alias RealworldPhoenix.Articles
  alias RealworldPhoenix.Repo
  alias RealworldPhoenix.Accounts
  alias RealworldPhoenix.Accounts.User
  alias RealworldPhoenix.Articles.Comment
  alias RealworldPhoenix.Articles.Article

  @valid_attrs %{
    body: "some body",
    description: "some description",
    tagList: [],
    title: "some title"
  }
  @update_attrs %{
    body: "some updated body",
    description: "some updated description",
    tagList: [],
    title: "some updated title"
  }
  @invalid_attrs %{
    body: nil,
    description: nil,
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

  describe "articles" do
    def favorite_fixture(user, article) do
      Articles.create_favorite(user, article)
    end

    test "list_articles/0 returns all articles" do
      article_fixture()
      assert is_list(Articles.list_articles())
    end

    test "list_articles/1 filtered by tagList" do
      article = article_fixture(%{tagList: ["Elixir", "Erlang"]})
      _othertagged_article = article_fixture(%{tagList: ["Java"]})
      [%{id: article_id}] = Articles.list_articles(tag: "Elixir")
      assert article_id == article.id
    end

    test "list_articles/1 filtered by author" do
      user = user_fixture(%{username: "hoge1"})
      other_user = user_fixture(%{username: "hoge2"})
      article = article_fixture(%{author_id: user.id})
      _other_article = article_fixture(%{author_id: other_user.id})

      [%{id: article_id}] = Articles.list_articles(author: "hoge1")
      assert article_id == article.id
    end

    test "list_articles/1 filtered by favorited" do
      user = user_fixture(%{username: "hoge1"})
      other_user = user_fixture(%{username: "hoge2"})
      article = article_fixture(%{author_id: user.id})
      _other_article = article_fixture(%{author_id: other_user.id})

      favorite_fixture(user, article)

      [%{id: article_id}] = Articles.list_articles(favorited: "hoge1")
      assert article_id == article.id
    end

    test "list_articles/1 limit and offset" do
      _article = article_fixture()
      article = article_fixture()
      _article = article_fixture()

      [%{id: article_id}] = Articles.list_articles(limit: 1, offset: 1)
      assert article_id == article.id
    end

    test "list_articles return value that should has favorited" do
      article1 = article_fixture()
      _article2 = article_fixture()

      user = user_fixture()
      favorite_fixture(user, article1)

      assert [%{favorited: true}, %{favorited: false}] = Articles.list_articles(user: user)
    end

    test "list_articles_feed/1 return favorited article" do
      article1 = article_fixture()
      _article2 = article_fixture()

      user = user_fixture()
      favorite_fixture(user, article1)

      [%{id: article_id}] = Articles.list_articles_feed(user)
      assert article_id == article1.id
    end

    test "get_article!/1 returns the article with given id" do
      article = article_fixture()
      assert %Article{} = Articles.get_article!(article.id)
    end

    test "get_article_by_slug/1 returns the article with slug" do
      article = article_fixture()
      assert %Article{} = Articles.get_article_by_slug(article.slug)
    end

    test "create_article/1 with valid data creates a article" do
      assert {:ok, %Article{} = article} = Articles.create_article(@valid_attrs)
      assert article.body == "some body"
      assert article.description == "some description"
      assert article.slug == "some-title"
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
      assert article.slug == "some-updated-title"
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
  end

  describe "comments" do
    @valid_comment_attrs %{
      body: "some comment body"
    }
    @invalid_comment_attrs %{
      body: nil
    }

    def favorite_comment(article, user, attr \\ %{}) do
      Articles.create_comment(attr, article, user)
    end

    test "create_article/3 with valid data creates a article" do
      article = article_fixture()
      user = user_fixture()

      assert {:ok, %Comment{} = comment} =
               Articles.create_comment(@valid_comment_attrs, article, user)

      assert comment.body == @valid_comment_attrs.body
    end

    test "create_article/3 invalid data returns error changeset" do
      Articles.create_comment(@invalid_comment_attrs, %Article{}, %User{})
    end
  end
end
