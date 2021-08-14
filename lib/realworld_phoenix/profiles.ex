defmodule RealworldPhoenix.Profiles do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias RealworldPhoenix.Repo

  alias RealworldPhoenix.Accounts.User
  alias RealworldPhoenix.Profiles.FollowRelated

  def get_by_username(username) do
    Repo.get_by!(User, username: username)
  end

  def following?(%User{} = user, %User{} = target) do
    Repo.get_by(FollowRelated, user_id: user.id, target_id: target.id)
    |> is_nil()
    |> Kernel.not()
  end

  def create_follow(%User{} = user, %User{} = target) do
    %FollowRelated{}
    |> FollowRelated.changeset(%{user_id: user.id, target_id: target.id})
    |> Repo.insert()
  end

  def delete_follow(%User{} = user, %User{} = target) do
    q =
      from fr in FollowRelated,
        where:
          fr.user_id == ^user.id and
            fr.target_id == ^target.id

    Repo.delete_all(q)
  end
end
