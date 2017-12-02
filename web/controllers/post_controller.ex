defmodule RedditClone.PostController do
  use RedditClone.Web, :controller

  alias RedditClone.Post
  alias RedditClone.PostRating
  alias RedditClone.User

  def index(conn, _params) do
    posts = Repo.all(Post |> order_by([p], desc: p.updated_at))
    conn
    |> render("index.json", posts: Enum.map(posts, &Post.preloaded/1), current_user: Guardian.Plug.current_resource(conn))
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
        |> render("show.json", post: Post.preloaded(post), current_user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(RedditClone.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    post = Repo.get!(Post, id)
    conn
    |> render("show.json", post: Post.preloaded(post), current_user: Guardian.Plug.current_resource(conn))
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    user = Guardian.Plug.current_resource(conn)
    post = Repo.get!(Post, id)
    if user.id != post.user_id do
      conn
      |> put_status(:bad_request)
      |> render("error.json", message: "You are not the author of this post.")
    else
      changeset = Post.changeset(post, post_params)

      case Repo.update(changeset) do
        {:ok, post} ->
          render(conn, "show.json", post: Post.preloaded(post), current_user: user)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(RedditClone.ChangesetView, "error.json", changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Repo.get(Post, id)

    if post != nil do
      Repo.delete(post)
      send_resp(conn, :no_content, "")
    else
      conn
      |> put_status(:not_found)
      |> render("error.json", message: "Post with id #{id} not found.")
    end
  end

  def rate_post(conn, %{"post_id" => post_id, "post_rating" => %{"rating" => rating}}) do
    post = Repo.get(Post, post_id)

    if post != nil do
      post = Post.preloaded(post)
      user = Guardian.Plug.current_resource(conn)
      |> User.with_post_ratings

      if PostRating.find_user_post_rating(user, post) != nil do
        conn
        |> put_status(:bad_request)
        |> render("error.json", message: "You have already rated this post.")
      else
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
      end
    else
      conn
      |> put_status(:not_found)
      |> render("error.json", message: "Post with id #{post_id} not found.")
    end
  end
end
