defmodule RealworldPhoenix.Articles.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  alias RealworldPhoenix.Accounts.User
  alias RealworldPhoenix.Articles.Article

  schema "comments" do
    field :body, :string
    belongs_to :author, User
    belongs_to :article, Article

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :author_id, :article_id])
    |> validate_required([:body, :author_id, :article_id])
  end
end
