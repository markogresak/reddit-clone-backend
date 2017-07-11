defmodule RedditClone.Router do
  use RedditClone.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
    plug Guardian.Plug.EnsureAuthenticated, handler: RedditClone.ApiAuthErrorHandlerController
  end

  scope "/api", RedditClone do
    pipe_through :api

    post "/login", UserController, :login
    resources "/users", UserController, only: [:show, :create]
    resources "/posts", PostController, only: [:index, :show]
    resources "/comments", CommentController, only: [:show]
  end

  scope "/api", RedditClone do
    pipe_through :api
    pipe_through :api_auth

    post "/logout", UserController, :logout
    resources "/users", UserController, only: [:update, :delete]
    resources "/posts", PostController, only: [:create, :update, :delete]
    resources "/comments", CommentController, only: [:create, :update, :delete]
    put "/posts/:post_id/rate", PostController, :rate_post, as: :post_rate
    put "/comments/:comment_id/rate", CommentController, :rate_comment, as: :comment_rate
  end
end
