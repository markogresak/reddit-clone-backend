defmodule RedditClone.CommentController do
  use RedditClone.Web, :controller

  alias RedditClone.Comment
  alias RedditClone.CommentRating
  alias RedditClone.User

  def show(conn, %{"id" => id}) do
    comment = Repo.get!(Comment, id)
    render(conn, "show.json", comment: Comment.preloaded(comment))
  end

  def create(conn, %{"comment" => comment_params}) do
    user = Guardian.Plug.current_resource(conn)
    changeset = Comment.changeset(%Comment{}, Map.merge(comment_params, %{"user_id" => user.id}))
    |> Ecto.Changeset.put_assoc(:user, user)

    case Repo.insert(changeset) do
      {:ok, comment} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", comment_path(conn, :show, comment))
        |> render("show.json", comment: Comment.preloaded(comment))
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(RedditClone.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "comment" => comment_params}) do
    comment = Repo.get!(Comment, id)
    changeset = Comment.changeset(comment, comment_params)

    case Repo.update(changeset) do
      {:ok, comment} ->
        render(conn, "show.json", comment: Comment.preloaded(comment))
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(RedditClone.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    comment = Repo.get!(Comment, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(comment)

    send_resp(conn, :no_content, "")
  end

  def rate_comment(conn, %{"comment_id" => comment_id, "comment_rating" => %{"rating" => rating}}) do
    comment = Repo.get(Comment, comment_id)

    if comment != nil do
      comment = Comment.preloaded(comment)
      user = Guardian.Plug.current_resource(conn)
      |> User.with_comment_ratings

      changeset = CommentRating.changeset(%CommentRating{}, %{ rating: rating, comment: comment, user: user })
      |> Ecto.Changeset.put_assoc(:comment, comment)
      |> Ecto.Changeset.put_assoc(:user, user)

      case Repo.insert_or_update(changeset) do
        {:ok, comment_rating} ->
          render(conn, "comment_rating.json", comment_rating: comment_rating)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(RedditClone.ChangesetView, "error.json", changeset: changeset)
      end
    else
      conn
      |> put_status(:not_found)
      |> render("error.json", message: "Comment with id #{comment_id} not found.")
    end
  end
end
