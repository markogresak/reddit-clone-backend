defmodule RedditClone.Router do
  use RedditClone.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", RedditClone do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit]
    resources "/posts", PostController, except: [:new, :edit]
    resources "/comments", CommentController, except: [:new, :edit]
  end
end
