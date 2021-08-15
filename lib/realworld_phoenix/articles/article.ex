defmodule RealworldPhoenix.Articles.Article do
  use Ecto.Schema
  import Ecto.Changeset

  alias RealworldPhoenix.Accounts.User
  alias RealworldPhoenix.Articles.Comment

  schema "articles" do
    field :body, :string
    field :description, :string
    field :favoritesCount, :integer
    field :slug, :string
    field :tagList, {:array, :string}
    field :title, :string
    belongs_to :author, User

    has_many :comments, Comment

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:slug, :title, :description, :body, :tagList, :favoritesCount, :author_id])
    |> cast_assoc(:author)
    |> validate_required([:slug, :title, :description, :body, :tagList])
  end
end
