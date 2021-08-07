defmodule RealworldPhoenix.Repo do
  use Ecto.Repo,
    otp_app: :realworld_phoenix,
    adapter: Ecto.Adapters.Postgres
end
