defmodule RealworldPhoenix.Articles.Article do
  use Ecto.Schema
  import Ecto.Changeset

  alias RealworldPhoenix.Repo
  alias RealworldPhoenix.Accounts.User
  alias RealworldPhoenix.Articles.Comment
  alias RealworldPhoenix.Articles.Favorite
  alias RealworldPhoenix.Articles.Tag
  alias RealworldPhoenix.Articles.ArticleTag

  schema "articles" do
    field :body, :string
    field :description, :string
    field :slug, :string
    field :title, :string
    belongs_to :author, User

    field :favorited, :boolean, virtual: true

    has_many :comments, Comment
    has_many :favorites, Favorite

    many_to_many :tagList, Tag, join_through: ArticleTag, on_replace: :delete

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :description, :body, :author_id])
    |> cast_assoc(:author)
    |> put_assoc(:tagList, parse_tags(attrs))
    |> validate_required([:title, :description, :body])
    |> title_to_slugify()
  end

  def title_to_slugify(changeset) do
    case get_change(changeset, :title) do
      nil -> changeset
      title -> put_change(changeset, :slug, slugify(title))
    end
  end

  defp slugify(title) do
    title |> String.downcase() |> String.replace(~r/[^\w-]+/u, "-")
  end

  defp parse_tags(params) do
    (params["tagList"] || params[:tagList] || [])
    |> Enum.map(&get_or_insert_tag/1)
  end

  defp get_or_insert_tag(name) do
    Repo.get_by(Tag, name: name) ||
      Repo.insert!(%Tag{name: name})
  end
end
