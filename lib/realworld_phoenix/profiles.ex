defmodule RealworldPhoenix.Profiles do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias RealworldPhoenix.Repo

  alias RealworldPhoenix.Accounts.User

  def get_by_username(username) do
    Repo.get_by!(User, username: username)
  end
end
