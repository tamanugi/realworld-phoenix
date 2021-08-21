defmodule RealworldPhoenix.Articles.Article do
  use Ecto.Schema
  import Ecto.Changeset

  alias RealworldPhoenix.Accounts.User
  alias RealworldPhoenix.Articles.Comment
  alias RealworldPhoenix.Articles.Favorite

  schema "articles" do
    field :body, :string
    field :description, :string
    field :favoritesCount, :integer
    field :slug, :string
    field :tagList, {:array, :string}
    field :title, :string
    belongs_to :author, User

    field :favorited, :boolean, virtual: true

    has_many :comments, Comment
    has_many :favorites, Favorite

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :description, :body, :tagList, :favoritesCount, :author_id])
    |> cast_assoc(:author)
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
end
