defmodule RedditClone.Post do
  use RedditClone.Web, :model

  schema "posts" do
    field :title, :string
    field :text, :string
    field :url, :string
    belongs_to :user, RedditClone.User
    has_many :comment, RedditClone.Commet

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:title, :text, :url])
    |> validate_required([:title, :text, :url])
  end
end
