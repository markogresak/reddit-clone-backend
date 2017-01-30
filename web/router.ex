defmodule RedditClone.Router do
  use RedditClone.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", RedditClone do
    pipe_through :api
  end
end
