defmodule RealworldPhoenix.Articles.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :name
    timestamps()
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name, name: :tags_name_index)
  end
end
