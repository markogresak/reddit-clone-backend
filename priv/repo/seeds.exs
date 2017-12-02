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


defmodule Lorem do
  @lorem_words String.split "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
  @word_count Enum.count @lorem_words

  def words(n_words) when n_words <= 0, do: []
  def words(n_words) when n_words <= @word_count, do: Enum.take(@lorem_words, n_words)
  def words(n_words), do: Enum.concat(Enum.take(@lorem_words, @word_count), words(n_words - @word_count))
end

defmodule RedditClone.Seeds do
  alias RedditClone.Repo
  alias RedditClone.User
  alias RedditClone.Post
  alias RedditClone.Comment
  alias RedditClone.PostRating
  import Ecto.Query, only: [from: 2]

  defp random(min, max) do
    :rand.uniform(max - min + 1) + (min - 1)
  end

  defp random_boolean() do
    :rand.uniform > 0.5
  end

  defp lorem_words(n_words) do
    n_words |> Lorem.words |> Enum.join(" ")
  end

  defp find_last_user_number() do
    query = from u in User, where: like(u.username, "user%"), select: u.username
    usernames = Repo.all(query)
    Enum.map(usernames, fn(username) -> String.split(username, "user") |> List.last |> String.to_integer end)
    |> Enum.sort(&(&1 >= &2))
    |> List.first
  end

  defp insert_user(i) do
    username = "user" <> to_string(i)
    if (Repo.get_by(User, username: username) != nil) do
      # recursively find first free username
      insert_user(i + 1)
    else
      Repo.insert! %User{
        username: username,
        encrypted_password: Comeonin.Bcrypt.hashpwsalt("asdf1234"),
      }
    end
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
      text: lorem_words(random(10, 250)),
      url: nil,
      user: post_user,
    }
  end

  defp insert_comment(comment_user, post, parent_comment) do
    Repo.insert! %Comment{
      text: lorem_words(random(5, 100)),
      user: comment_user,
      post: post,
      parent_comment: parent_comment,
    }
  end

  defp insert_post_rating(rating_user, post) do
    Repo.insert! %PostRating{
      rating: (if random_boolean(), do: 1, else: -1),
      user: rating_user,
      post: post
    }
  end

  defp seed_nested_comments(users, post, parent_comment, nesting_depth) do
    if nesting_depth > 0 do
      IO.puts "Seeding nested comments (depth=#{nesting_depth})"
      number_of_comments = random(0, 4)
      if (number_of_comments > 0) do
        Enum.map(1..number_of_comments, fn(_i) ->
          comment_user = Enum.random(users)
          comment = insert_comment(comment_user, post, parent_comment)
          seed_nested_comments(users, post, comment, nesting_depth - 1)
        end)
      else
        # return [] to avoid returning nil, which breaks Enum.flat_map
        []
      end
    else
      # return [] to avoid returning nil, which breaks Enum.flat_map
      []
    end
  end

  def run() do
    IO.puts "This will generate 10 users and posts + comments. It will recursively search for usernames user{i}, which might be slow."
    user_input = String.trim(IO.gets "Are you sure you want to proceed? [y/n] ")
    if (user_input == "y") do
      IO.puts "Seeding users"
      last_user_number = find_last_user_number() || 1
      # insert 10 users
      users = Enum.map(last_user_number..(last_user_number + 9), &(insert_user(&1)))

      IO.puts "Seeding posts"
      # iterate 10 times, each time insert 2-5 posts for a total of 20-50 posts
      posts = Enum.flat_map(1..10, fn(i) ->
        insert_fn = if (rem(i, 2) == 0), do: &insert_post_with_url/2, else: &insert_post_with_text/2
        post_user = Enum.random(users)
        Enum.map(1..(random(2, 5)), &(insert_fn.(i * 10 + &1, post_user)))
      end)

      IO.puts "Seeding comments"
      # for each post, insert random number of comments
      _comments = Enum.flat_map(posts, fn(post) ->
        number_of_comments = random(0, 10)
        if (number_of_comments > 0) do
          Enum.map(1..number_of_comments, fn(_i) ->
            comment_user = Enum.random(users)
            comment = insert_comment(comment_user, post, nil)
            Enum.concat([comment], seed_nested_comments(users, post, comment, random(0, 3)))
          end)
        else
          # return [] to avoid returning nil, which breaks Enum.flat_map
          []
        end
      end)

      IO.puts "Seeding post ratings"
      # for each post, insert random number of ratings
      _post_ratings = Enum.flat_map(posts, fn(post) ->
        number_of_post_ratings = random(0, 50)
        if (number_of_post_ratings > 0) do
          post_rating_user = Enum.random(users)
          Enum.map(1..number_of_post_ratings, fn(_i) -> insert_post_rating(post_rating_user, post) end)
        else
          # return [] to avoid returning nil, which breaks Enum.flat_map
          []
        end
      end)

      IO.puts "Inserted users:"
      Enum.each(users, fn(user) -> IO.puts "\t#{user.username}" end)
      IO.puts "All usernames above have password: asdf1234"
    end
  end
end

RedditClone.Seeds.run()
