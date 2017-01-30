defmodule RedditClone.Comment do
  use RedditClone.Web, :model

  schema "comments" do
    field :text, :string
    belongs_to :user, RedditClone.User
    belongs_to :post, RedditClone.Post

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:text])
    |> validate_required([:text])
    |> validate_length(:text, min: 1)
  end
end
