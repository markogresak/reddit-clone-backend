defmodule RedditClone.PostView do
  use RedditClone.Web, :view

  def render("index.json", %{posts: posts}) do
    %{data: render_many(posts, RedditClone.PostView, "post-shallow.json")}
  end

  def render("show.json", %{post: post}) do
    %{data: render_one(post, RedditClone.PostView, "post.json")}
  end

  def render("post-shallow.json", %{post: post}) do
    %{
      id: post.id,
      title: post.title,
      url: post.url,
      user_id: post.user_id,
      comment_count: RedditClone.Post.comment_count(post),
      rating: RedditClone.Post.total_rating(post),
      submitted_at: post.inserted_at,
    }
  end

  def render("post.json", %{post: post}) do
    post_comments = %{
      text: post.text,
      comments: render_many(post.comments, RedditClone.CommentView, "comment.json"),
    }

    render_one(post, RedditClone.PostView, "post-shallow.json")
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
