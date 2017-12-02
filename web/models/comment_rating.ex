defmodule RedditClone.CommentRating do
  use RedditClone.Web, :model

  schema "comment_ratings" do
    field :rating, :integer
    belongs_to :user, RedditClone.User
    belongs_to :comment, RedditClone.Comment

    timestamps()
  end

  def find_user_comment_rating(user, comment) do
    if user != nil do
      query = from cr in RedditClone.CommentRating,
              where: cr.user_id == ^user.id and cr.comment_id == ^comment.id,
              select: cr.rating
      RedditClone.Repo.one(query)
    else
      # User resource does not exist (not logged in), no way to find PostRating.
      nil
    end
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:rating])
    |> validate_required([:rating])
    |> validate_inclusion(:rating, [-1, 1])
  end
end
