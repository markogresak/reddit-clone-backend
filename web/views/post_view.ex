defmodule RedditClone.PostView do
  use RedditClone.Web, :view

  def render("index.json", %{posts: posts}) do
    %{data: render_many(posts, RedditClone.PostView, "post.json")}
  end

  def render("show.json", %{post: post}) do
    %{data: render_one(post, RedditClone.PostView, "post.json")}
  end

  def render("post-shallow.json", %{post: post}) do
    %{
      id: post.id,
      title: post.title,
      text: post.text,
      url: post.url,
      user_id: post.user_id,
    }
  end

  def render("post.json", %{post: post}) do
    post_comments = %{comments: render_many(post.comments, RedditClone.CommentView, "comment.json")}
    Map.merge(render_one(post, RedditClone.PostView, "post-shallow.json"), post_comments)
  end
end
