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
  http: [compress: true],
  url: [host: "localhost"],
  secret_key_base: "ZxQB/fx7OgNjirBNWY8nNoaLu1Wehk+R2TphM5mlK+ht9TOsS0YQSB41FkbCuY9w",
  render_errors: [view: RedditClone.ErrorView, accepts: ~w(json)],
  pubsub: [name: RedditClone.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :guardian, Guardian,
  allowed_algos: ["HS512"],
  verify_module: Guardian.JWT,
  issuer: "RedditClone",
  ttl: { 30, :days },
  allowed_drift: 2000,
  verify_issuer: true,
  secret_key: System.get_env("GUARDIAN_KEY") || "6g9NaWbJSrr8aFTQUW2819XoK9I4HMZUdZARxJu0yJqH+4nvm70OQAzzEM7xMYab",
  serializer: RedditClone.GuardianSerializer

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
