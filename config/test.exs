use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :reddit_clone, RedditClone.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :reddit_clone, RedditClone.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "reddit_clone_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# for faster encryption (only in test env)
config :comeonin, :bcrypt_log_rounds, 4
config :comeonin, :pbkdf2_rounds, 1

# Configure your database
config :reddit_clone, RedditClone.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "reddit_clone_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
