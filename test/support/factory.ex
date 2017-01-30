defmodule RedditClone.Factory do
  use ExMachina.Ecto, repo: RedditClone.Repo
  use Comeonin.Bcrypt

  def user_factory do
    %RedditClone.User{
      username: "test_user",
      encrypted_password: hashpwsalt("pass1234"),
    }
  end

  def post_url_factory do
    %RedditClone.Post{
      title: "Title of post with url",
      text: nil,
      url: "http://example.com",
      user: build(:user),
    }
  end

  def post_text_factory do
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
      post: build(:post_url),
    }
  end
end
