# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :realworld_phoenix,
  ecto_repos: [RealworldPhoenix.Repo]

# Configures the endpoint
config :realworld_phoenix, RealworldPhoenixWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "KbigaHrG8gITCGeAFr9qvt/Egzrb4Q5p/Sxb5tPDV6niq4Alk86UyE9VLF20eugl",
  render_errors: [view: RealworldPhoenixWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: RealworldPhoenix.PubSub,
  live_view: [signing_salt: "N4t1juCl"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
