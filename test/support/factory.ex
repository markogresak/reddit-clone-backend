defmodule RedditClone.Factory do
  use ExMachina.Ecto, repo: RedditClone.Repo

  def user_factory do
    %RedditClone.User{
      username: sequence("test_user"),
      encrypted_password: Comeonin.Bcrypt.hashpwsalt("pass1234"),
    }
  end

  def user2_factory do
    %RedditClone.User{
      username: sequence("test_user_2"),
      encrypted_password: Comeonin.Bcrypt.hashpwsalt("pass1234"),
    }
  end

  def user_login_factory do
    %RedditClone.User{
      username: "user_login",
      encrypted_password: Comeonin.Bcrypt.hashpwsalt("pass123"),
    }
  end

  def post_with_url_factory do
    %RedditClone.Post{
      title: "Title of post with url",
      text: nil,
      url: "http://example.com",
      user: build(:user),
    }
  end

  def post_with_text_factory do
    %RedditClone.Post{
      title: "Title of post with text",
      text: "Post text",
      url: nil,
      user: build(:user),
    }
  end

  def comment_factory do
    %RedditClone.Comment{
      text: "A comment",
      user: build(:user),
      post: build(:post_with_url),
    }
  end

  def post_rating_up_factory do
    %RedditClone.PostRating{
      rating: 1,
      user: build(:user),
      post: build(:post_with_url),
    }
  end

  def post_rating_down_factory do
    %RedditClone.PostRating{
      rating: -1,
      user: build(:user),
      post: build(:post_with_url),
    }
  end

  def comment_rating_up_factory do
    %RedditClone.CommentRating{
      rating: 1,
      user: build(:user),
      comment: build(:comment),
    }
  end

  def comment_rating_down_factory do
    %RedditClone.CommentRating{
      rating: -1,
      user: build(:user),
      comment: build(:comment),
    }
  end
end
