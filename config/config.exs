# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :prime_reading_watcher,
  ecto_repos: [PrimeReadingWatcher.Repo]

# Configures the endpoint
config :prime_reading_watcher, PrimeReadingWatcherWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "O9P5ZbbRYJqr305s12M2shdTrjqzfhDckdT9uaY7L7XRsPjs9Fp5hxRBMEzCvtQ+",
  render_errors: [view: PrimeReadingWatcherWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PrimeReadingWatcher.PubSub, adapter: Phoenix.PubSub.PG2]

config :prime_reading_watcher, :aws_key,
  key: System.get_env("AWS_ACCESS_KEY"),
  sec: System.get_env("AWS_ACCESS_SECRET")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
