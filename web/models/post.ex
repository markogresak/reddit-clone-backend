defmodule RedditClone.Post do
  use RedditClone.Web, :model

  schema "posts" do
    field :title, :string
    field :text, :string
    field :url, :string
    belongs_to :user, RedditClone.User
    has_many :comments, RedditClone.Comment

    timestamps()
  end

  def with_comments(post) do
    post
    |> RedditClone.Repo.preload([:comments])
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title])
    |> validate_required([:title])
    |> validate_length(:title, min: 1)
  end
end
