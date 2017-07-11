defmodule RedditClone.PostController do
  use RedditClone.Web, :controller

  alias RedditClone.Post
  alias RedditClone.PostRating

  def index(conn, _params) do
    posts = Repo.all(Post)
    render(conn, "index.json", posts: Enum.map(posts, &preload_post_relations/1))
  end

  def create(conn, %{"post" => post_params}) do
    user = Guardian.Plug.current_resource(conn)
    changeset = Post.changeset(%Post{}, Map.merge(post_params, %{"user_id" => user.id}))
    |> Ecto.Changeset.put_assoc(:user, user)

    case Repo.insert(changeset) do
      {:ok, post} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", post_path(conn, :show, post))
        |> render("show.json", post: preload_post_relations(post))
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(RedditClone.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)
    render(conn, "show.json", post: preload_post_relations(post))
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Repo.get!(Post, id)
    changeset = Post.changeset(post, post_params)

    case Repo.update(changeset) do
      {:ok, post} ->
        render(conn, "show.json", post: preload_post_relations(post))
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(RedditClone.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(post)

    send_resp(conn, :no_content, "")
  end

  def rate_post(conn, %{"post_id" => post_id, "post_rating" => %{"rating" => rating}}) do
    post = Repo.get(Post, post_id)

    if post != nil do
      post = preload_post_relations(post)
      user = Guardian.Plug.current_resource(conn)
      |> RedditClone.Repo.preload([:post_ratings])

      changeset = PostRating.changeset(%PostRating{}, %{ rating: rating, post: post, user: user })
      |> Ecto.Changeset.put_assoc(:post, post)
      |> Ecto.Changeset.put_assoc(:user, user)

      case Repo.insert_or_update(changeset) do
        {:ok, post_rating} ->
          render(conn, "post_rating.json", post_rating: post_rating, post: post)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(RedditClone.ChangesetView, "error.json", changeset: changeset)
      end
    else
      conn
      |> put_status(:not_found)
      |> render("error.json", message: "Post with id #{post_id} not found.")
    end
  end

  defp preload_post_relations(post) do
    post
    |> Post.with_comments
    |> Post.with_ratings
  end
end
