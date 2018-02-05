defmodule RedditClone.Endpoint do
  use Phoenix.Endpoint, otp_app: :reddit_clone

  socket "/socket", RedditClone.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :reddit_clone, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_reddit_clone_key",
    signing_salt: "yVx9yhQM"

  # Match origin localhost:[port], gresak.io (and all subdomains) or markogresak.github.io
  plug CORSPlug, origin: ~r/(http:\/\/localhost:\d+$|https?.*gresak\.io$|https:\/\/markogresak\.github\.io$)/

  plug RedditClone.Router
end
