defmodule RedditClone.Repo.Migrations.CreatePostRating do
  use Ecto.Migration

  def change do
    create table(:post_ratings) do
      add :rating, :integer
      add :user_id, references(:users, on_delete: :nothing)
      add :post_id, references(:posts, on_delete: :nothing)

      timestamps()
    end
    create index(:post_ratings, [:user_id])
    create index(:post_ratings, [:post_id])

  end
end
