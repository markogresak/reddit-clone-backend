defmodule RedditClone.PostRating do
  use RedditClone.Web, :model

  schema "post_ratings" do
    field :rating, :integer
    belongs_to :user, RedditClone.User
    belongs_to :post, RedditClone.Post

    timestamps()
  end

  def find_user_post_rating(user, post) do
    if user != nil do
      query = from pr in RedditClone.PostRating,
              where: pr.user_id == ^user.id and pr.post_id == ^post.id,
              select: pr.rating
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
