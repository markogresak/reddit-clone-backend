defmodule RedditClone.User do
  use RedditClone.Web, :model

  schema "users" do
    field :username, :string
    field :encrypted_password, :string
    field :password, :string, virtual: true
    has_many :posts, RedditClone.Post
    has_many :comments, RedditClone.Comment
    has_many :post_ratings, RedditClone.PostRating, on_delete: :delete_all, on_replace: :delete

    timestamps()
  end

  def with_posts(user) do
    user
    |> RedditClone.Repo.preload([:posts])
  end

  def with_comments(user) do
    user
    |> RedditClone.Repo.preload([:comments])
  end

  def find_and_confirm_password(params) do
    changeset = registration_changeset(%RedditClone.User{}, params)

    if changeset.valid? do
      %{username: username, password: password} = changeset.changes
      user = RedditClone.Repo.get_by(RedditClone.User, username: username)
      if Comeonin.Bcrypt.checkpw(password, user.encrypted_password) do
        {:ok, user}
      else
        {:error, %{}}
      end
    end

  end

  def find_user_post_rating(user) do
    query = from pr in RedditClone.PostRating,
            where: pr.user_id == ^user.id,
            select: pr
    RedditClone.Repo.one(query)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username])
    |> cast_assoc(:post_ratings)
    |> validate_required([:username])
    |> unique_constraint(:username)
    |> validate_length(:username, min: 3)
  end

  def registration_changeset(struct, params \\ :empty) do
    struct
    |> changeset(params)
    |> cast(params, [:password])
    |> validate_length(:password, min: 6)
    |> put_password_hash
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :encrypted_password, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
