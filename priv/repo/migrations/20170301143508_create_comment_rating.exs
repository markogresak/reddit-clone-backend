defmodule RedditClone.Repo.Migrations.CreateCommentRating do
  use Ecto.Migration

  def change do
    create table(:comment_ratings) do
      add :rating, :integer
      add :user_id, references(:users, on_delete: :nothing)
      add :comment_id, references(:comments, on_delete: :nothing)

      timestamps()
    end
    create index(:comment_ratings, [:user_id])
    create index(:comment_ratings, [:comment_id])

  end
end
