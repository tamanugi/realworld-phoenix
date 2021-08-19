defmodule RealworldPhoenix.Articles do
  @moduledoc """
  The Articles context.
  """

  import Ecto.Query, warn: false
  alias RealworldPhoenix.Repo

  alias RealworldPhoenix.Articles.Article
  alias RealworldPhoenix.Articles.Comment
  alias RealworldPhoenix.Accounts.User
  alias RealworldPhoenix.Articles.Favorite

  # require Kernel

  @doc """
  Returns the list of articles.

  ## Examples

      iex> list_articles()
      [%Article{}, ...]

  """
  def list_articles(params \\ []) do
    from(a in Article)
    |> article_where(params)
    |> Repo.all()
  end

  def article_where(query, []), do: query

  def article_where(query, [{:tag, tag} | rest]) do
    query
    |> where([a], ^tag in a.tagList)
    |> article_where(rest)
  end

  def article_where(query, [{:author, author_name} | rest]) do
    query
    |> join(:inner, [a], author in User, as: :author, on: a.author_id == author.id)
    |> where([author: author], author.username == ^author_name)
    |> article_where(rest)
  end

  def article_where(query, [{:favorited, favorited} | rest]) do
    query
    |> join(:left, [a], f in Favorite, as: :favorite, on: a.id == f.article_id)
    |> join(:left, [favorite: f], fu in User, as: :favorite_user, on: f.user_id == fu.id)
    |> where([favorite_user: fu], fu.username == ^favorited)
    |> article_where(rest)
  end

  @doc """
  Gets a single article.

  Raises `Ecto.NoResultsError` if the Article does not exist.

  ## Examples

      iex> get_article!(123)
      %Article{}

      iex> get_article!(456)
      ** (Ecto.NoResultsError)

  """
  def get_article!(id), do: Repo.get!(Article, id) |> Repo.preload(:author)

  def get_article_by_slug!(slug) do
    Repo.get_by(Article, slug: slug)
  end

  @doc """
  Creates a article.

  ## Examples

      iex> create_article(%{field: value})
      {:ok, %Article{}}

      iex> create_article(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_article(attrs \\ %{}) do
    %Article{}
    |> Article.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a article.

  ## Examples

      iex> update_article(article, %{field: new_value})
      {:ok, %Article{}}

      iex> update_article(article, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_article(%Article{} = article, attrs) do
    article
    |> Article.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a article.

  ## Examples

      iex> delete_article(article)
      {:ok, %Article{}}

      iex> delete_article(article)
      {:error, %Ecto.Changeset{}}

  """
  def delete_article(%Article{} = article) do
    Repo.delete(article)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking article changes.

  ## Examples

      iex> change_article(article)
      %Ecto.Changeset{data: %Article{}}

  """
  def change_article(%Article{} = article, attrs \\ %{}) do
    Article.changeset(article, attrs)
  end

  def create_comment(attrs) do
    Comment.changeset(%Comment{}, attrs)
    |> Repo.insert()
  end

  def create_comment(comment, %Article{} = article, %User{} = author) do
    attrs =
      comment
      |> Map.put(:article_id, article.id)
      |> Map.put(:author_id, author.id)

    Comment.changeset(%Comment{}, attrs)
    |> Repo.insert()
  end

  def list_comment_by_article_slug(slug, user_id) do
    q =
      from c in Comment,
        join: at in assoc(c, :author),
        join: a in Article,
        on: c.article_id == a.id,
        left_join: fr in RealworldPhoenix.Profiles.FollowRelated,
        on: fr.target_id == c.author_id and fr.user_id == ^user_id,
        where: a.slug == ^slug,
        select_merge: %{author: merge(at, %{following: not is_nil(fr)})}

    Repo.all(q)
  end

  def get_comment!(id) do
    Repo.get!(Comment, id)
  end

  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  alias RealworldPhoenix.Articles.Favorite

  def create_favorite(%User{} = user, %Article{} = article) do
    %Favorite{}
    |> Favorite.changeset(%{user_id: user.id, article_id: article.id})
    |> Repo.insert()
  end

  def delete_favorite(%User{} = user, %Article{} = article) do
    from(f in Favorite,
      where:
        f.user_id == ^user.id and
          f.article_id ==
            ^article.id
    )
    |> Repo.delete_all()
  end
end
