defmodule RealworldPhoenix.Articles.Article do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field :body, :string
    field :description, :string
    field :favoritesCount, :integer
    field :slug, :string
    field :tagList, {:array, :string}
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:slug, :title, :description, :body, :tagList, :favoritesCount])
    |> validate_required([:slug, :title, :description, :body, :tagList, :favoritesCount])
  end
end
