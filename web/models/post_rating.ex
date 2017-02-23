defmodule RedditClone.PostRating do
  use RedditClone.Web, :model

  schema "post_ratings" do
    field :rating, :integer
    belongs_to :user, RedditClone.User
    belongs_to :post, RedditClone.Post

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
