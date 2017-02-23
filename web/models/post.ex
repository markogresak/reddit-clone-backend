defmodule RedditClone.Post do
  use RedditClone.Web, :model

  schema "posts" do
    field :title, :string
    field :text, :string
    field :url, :string
    belongs_to :user, RedditClone.User
    has_many :comments, RedditClone.Comment
    has_many :ratings, RedditClone.PostRating, on_delete: :delete_all, on_replace: :delete

    timestamps()
  end

  def with_comments(post) do
    post
    |> RedditClone.Repo.preload([:comments])
  end

  def with_ratings(post) do
    post
    |> RedditClone.Repo.preload([:ratings])
  end

  def comment_count(post) do
    Enum.count(RedditClone.Post.with_comments(post).comments)
  end

  def total_rating(post) do
    query = from pr in RedditClone.PostRating,
            where: pr.post_id == ^post.id,
            select: sum(pr.rating)
    RedditClone.Repo.one(query) || 0
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title])
    |> cast_assoc(:ratings)
    |> validate_required([:title])
    |> validate_length(:title, min: 1)
  end
end
