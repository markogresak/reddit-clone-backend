defmodule RedditClone.PostView do
  use RedditClone.Web, :view

  def render("index.json", %{posts: posts, current_user: current_user}) do
    %{data: render_many(posts, RedditClone.PostView, "post-shallow.json", current_user: current_user)}
  end

  def render("show.json", %{post: post, current_user: current_user}) do
    %{data: render_one(post, RedditClone.PostView, "post.json", current_user: current_user)}
  end

  def render("post-shallow.json", %{post: post, current_user: current_user}) do
    %{
      id: post.id,
      title: post.title,
      url: post.url,
      user: %{
        id: post.user.id,
        username: post.user.username,
      },
      comment_count: RedditClone.Post.comment_count(post),
      rating: RedditClone.Post.total_rating(post),
      submitted_at: post.inserted_at,
      user_post_rating: RedditClone.PostRating.find_user_post_rating(current_user, post),
    }
  end

  def render("post.json", %{post: post, current_user: current_user}) do
    post_comments = %{
      text: post.text,
      comments: render_many(post.comments, RedditClone.CommentView, "comment.json", current_user: current_user),
    }

    render_one(post, RedditClone.PostView, "post-shallow.json", current_user: current_user)
    |> Map.merge(post_comments)
  end

  def render("post_rating.json", %{post_rating: post_rating, post: post}) do
    %{
      data: %{
        rating: post_rating.rating,
        post_id: post.id,
        post_rating: RedditClone.Post.total_rating(post),
      }
    }
  end

  def render("error.json", %{message: message}) do
    %{
      error: %{message: message}
    }
  end
end
