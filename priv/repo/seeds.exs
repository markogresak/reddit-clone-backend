# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     RedditClone.Repo.insert!(%RedditClone.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


defmodule RedditClone.Seeds do
  alias RedditClone.Repo
  alias RedditClone.User
  alias RedditClone.Post
  alias RedditClone.Comment

  defp random(min, max) do
    :rand.uniform(max - min + 1) + (min - 1)
  end

  defp insert_user(i) do
    Repo.insert! %User{
      username: "user" <> to_string(i),
      encrypted_password: Comeonin.Bcrypt.hashpwsalt("pass1234"),
    }
  end

  defp insert_post_with_url(i, post_user) do
    Repo.insert! %Post{
      title: "Post " <> to_string(i) <> " (with url)",
      text: nil,
      url: "http://example.com",
      user: post_user,
    }
  end

  defp insert_post_with_text(i, post_user) do
    Repo.insert! %Post{
      title: "Post " <> to_string(i) <> " (with text)",
      text: Elixilorem.words(random(10, 250)),
      url: nil,
      user: post_user,
    }
  end

  defp insert_comment(comment_user, post) do
    Repo.insert! %Comment{
      text: Elixilorem.words(random(5, 100)),
      user: comment_user,
      post: post,
    }
  end

  def run() do
    IO.puts "Seeding users"
    # insert 10 users
    users = Enum.map(1..10, &(insert_user(&1)))

    IO.puts "Seeding posts"
    # iterate 10 times, each time insert 2-5 posts for a total of 20-50 posts
    posts = Enum.flat_map(1..10, fn(i) ->
      insert_fn = if (rem(i, 2) == 0), do: &insert_post_with_url/2, else: &insert_post_with_text/2
      post_user = Enum.random(users)
      Enum.map(1..(random(2, 5)), &(insert_fn.(i * 10 + &1, post_user)))
    end)

    IO.puts "Seeding comments"
    # for each post, insert random number of comments
    Enum.each(posts, fn(post) ->
      number_of_comments = random(0, 20)
      if (number_of_comments > 0) do
        comment_user = Enum.random(users)
        Enum.each(1..number_of_comments, fn(_i) -> insert_comment(comment_user, post) end)
      end
    end)
  end
end

RedditClone.Seeds.run()
