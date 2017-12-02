defmodule RedditClone.UserView do
  use RedditClone.Web, :view

  def render("show.json", %{user: user, current_user: current_user}) do
    %{data: render_one(user, RedditClone.UserView, "user.json", current_user: current_user)}
  end

  def render("user.json", %{user: user, current_user: current_user}) do
    %{
      id: user.id,
      username: user.username,
      comments: render_many(user.comments, RedditClone.CommentView, "comment.json", current_user: current_user),
      posts: render_many(user.posts, RedditClone.PostView, "post-shallow.json", current_user: current_user)
    }
  end

  def render("user-shallow.json", %{user: user}) do
    %{
      id: user.id,
      username: user.username,
    }
  end

  def render("login.json", %{user: user, jwt: jwt, exp: exp}) do
    %{
      data: %{
        user: render_one(user, RedditClone.UserView, "user-shallow.json"),
        jwt: jwt,
        exp: exp
      }
    }
  end

  def render("error.json", %{message: message}) do
    %{
      error: %{message: message}
    }
  end
end
