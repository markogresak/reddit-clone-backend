defmodule RedditClone.Comment do
  use RedditClone.Web, :model

  schema "comments" do
    field :text, :string
    belongs_to :user, RedditClone.User
    belongs_to :post, RedditClone.Post
    belongs_to :parent_comment, RedditClone.Comment
    has_many :ratings, RedditClone.CommentRating, on_delete: :delete_all, on_replace: :delete

    timestamps()
  end

  def preloaded(comment) do
    comment
    |> RedditClone.Repo.preload([:user, :ratings])
  end

  def total_rating(comment) do
    query = from cr in RedditClone.CommentRating,
            where: cr.comment_id == ^comment.id,
            select: sum(cr.rating)
    RedditClone.Repo.one(query) || 0
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:text])
    |> cast_assoc(:ratings)
    |> validate_required([:text])
    |> validate_length(:text, min: 1)
  end
end
