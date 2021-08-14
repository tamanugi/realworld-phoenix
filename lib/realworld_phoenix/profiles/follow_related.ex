defmodule RealworldPhoenix.Profiles.FollowRelated do
  use Ecto.Schema
  import Ecto.Changeset

  alias RealworldPhoenix.Accounts.User

  @already_exists "ALREADY_EXISTS"

  @primary_key false
  schema "follow_related" do
    belongs_to(:user, User, primary_key: true)
    belongs_to(:target, User, primary_key: true)

    timestamps()
  end

  @doc false
  def changeset(follow_related, attrs) do
    follow_related
    |> cast(attrs, [:user_id, :target_id])
    |> validate_required([:user_id, :target_id])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:target_id)
    |> unique_constraint([:user, :target],
      name: :user_id_target_id_unique_index,
      message: @already_exists
    )
  end
end
