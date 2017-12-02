defmodule RedditClone.CommentView do
  use RedditClone.Web, :view

  def render("show.json", %{comment: comment, current_user: current_user}) do
    %{data: render_one(comment, RedditClone.CommentView, "comment.json", current_user: current_user)}
  end

  def render("comment.json", %{comment: comment, current_user: current_user}) do
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
      submitted_at: comment.inserted_at,
      user_comment_rating: RedditClone.CommentRating.find_user_comment_rating(current_user, comment),
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
