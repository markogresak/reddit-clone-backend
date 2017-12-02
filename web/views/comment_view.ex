defmodule RedditClone.CommentView do
  use RedditClone.Web, :view

  def render("index.json", %{comments: comments}) do
    %{data: render_many(comments, RedditClone.CommentView, "comment.json")}
  end

  def render("show.json", %{comment: comment}) do
    %{data: render_one(comment, RedditClone.CommentView, "comment.json")}
  end

  def render("comment.json", %{comment: comment}) do
    %{
      id: comment.id,
      text: comment.text,
      user: %{
        id: comment.user.id,
        username: comment.user.username,
      },
      post_id: comment.post_id,
      rating: RedditClone.Comment.total_rating(comment),
      parent_comment_id: comment.parent_comment_id,
    }
  end

  def render("comment_rating.json", %{comment_rating: comment_rating}) do
    %{
      data: %{
        rating: comment_rating.rating
      }
    }
  end

  def render("error.json", %{message: message}) do
    %{
      error: %{message: message}
    }
  end
end
