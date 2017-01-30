# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :reddit_clone,
  ecto_repos: [RedditClone.Repo]

# Configures the endpoint
config :reddit_clone, RedditClone.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ZxQB/fx7OgNjirBNWY8nNoaLu1Wehk+R2TphM5mlK+ht9TOsS0YQSB41FkbCuY9w",
  render_errors: [view: RedditClone.ErrorView, accepts: ~w(json)],
  pubsub: [name: RedditClone.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
