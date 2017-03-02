defmodule RedditClone.CommentRating do
  use RedditClone.Web, :model

  schema "comment_ratings" do
    field :rating, :integer
    belongs_to :user, RedditClone.User
    belongs_to :comment, RedditClone.Comment

    timestamps()
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
