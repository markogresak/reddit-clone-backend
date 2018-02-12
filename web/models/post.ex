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

  def preloaded(post) do
    post
    |> RedditClone.Repo.preload([:user, :ratings, comments: :user])
  end

  def comment_count(post) do
    query = from pc in RedditClone.Comment,
            where: pc.post_id == ^post.id,
            select: count(pc.id)
    RedditClone.Repo.one(query) || 0
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
    |> cast(params, [:title, :url, :text])
    |> cast_assoc(:comments)
    |> cast_assoc(:ratings)
    |> validate_required([:title])
    |> validate_required_inclusion([:url, :text])
    |> validate_length(:title, min: 1)
  end

  defp validate_required_inclusion(changeset, fields) do
    if Enum.any?(fields, fn(field) -> get_field(changeset, field) end),
      do: changeset,
      else: add_error(changeset, hd(fields), "One of these fields must be present: #{inspect fields}")
  end
end
