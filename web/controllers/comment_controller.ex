defmodule RedditClone.CommentController do
  use RedditClone.Web, :controller

  alias RedditClone.Comment
  alias RedditClone.CommentRating
  alias RedditClone.User
  alias RedditClone.Post

  def show(conn, %{"id" => id}) do
    comment = Repo.get!(Comment, id)
    render(conn, "show.json", comment: Comment.preloaded(comment), current_user: Guardian.Plug.current_resource(conn))
  end

  def create(conn, %{"comment" => comment_params}) do
    user = Guardian.Plug.current_resource(conn)
    changeset = Comment.changeset(%Comment{}, Map.merge(comment_params, %{"user_id" => user.id}))
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Ecto.Changeset.put_assoc(:post, Repo.get!(Post, comment_params["post_id"]))
    |> (fn (changeset) ->
      case Map.has_key?(comment_params, "parent_comment_id") do
        true ->
          parent_comment = Repo.get!(Comment, comment_params["parent_comment_id"])
          Ecto.Changeset.put_assoc(changeset, :parent_comment, parent_comment)
        false ->
          changeset
      end
    end).()

    case Repo.insert(changeset) do
      {:ok, comment} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", comment_path(conn, :show, comment))
        |> render("show.json", comment: Comment.preloaded(comment), current_user: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(RedditClone.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "comment" => comment_params}) do
    user = Guardian.Plug.current_resource(conn)
    comment = Repo.get!(Comment, id)

    if user.id != comment.user_id do
      conn
      |> put_status(:bad_request)
      |> render("error.json", message: "You are not the author of this comment.")
    else
      changeset = Comment.changeset(comment, comment_params)

      case Repo.update(changeset) do
        {:ok, comment} ->
          render(conn, "show.json", comment: Comment.preloaded(comment), current_user: user)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(RedditClone.ChangesetView, "error.json", changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    comment = Repo.get!(Comment, id)

    if user.id != comment.user_id do
      conn
      |> put_status(:bad_request)
      |> render("error.json", message: "You are not the author of this comment.")
    else
      if comment != nil do
        Repo.delete(comment)
        send_resp(conn, :no_content, "")
      else
        conn
        |> put_status(:not_found)
        |> render("error.json", message: "Comment with id #{id} not found.")
      end
    end
  end

  def rate_comment(conn, %{"comment_id" => comment_id, "comment_rating" => %{"rating" => rating}}) do
    comment = Repo.get(Comment, comment_id)

    if comment != nil do
      comment = Comment.preloaded(comment)
      user = Guardian.Plug.current_resource(conn)
      |> User.with_comment_ratings

      # Remove all previous ratings.
      from(pr in RedditClone.CommentRating,
        where: pr.user_id == ^user.id and pr.comment_id == ^comment.id)
      |> Repo.delete_all

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
