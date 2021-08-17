defmodule RealworldPhoenix.Articles.Favorite do
  use Ecto.Schema
  import Ecto.Changeset

  alias RealworldPhoenix.Accounts.User
  alias RealworldPhoenix.Articles.Article

  @already_exists "ALREADY_EXISTS"

  schema "favorites" do
    belongs_to(:user, User, primary_key: true)
    belongs_to(:article, Article, primary_key: true)

    timestamps()
  end

  @doc false
  def changeset(favorite, attrs) do
    favorite
    |> cast(attrs, [:user_id, :article_id])
    |> validate_required([:user_id, :article_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:article_id)
    |> unique_constraint([:user, :article],
      name: :user_id_article_id_unique_index,
      message: @already_exists
    )
  end
end
