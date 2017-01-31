defmodule RedditClone.Repo.Migrations.CreateComment do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :text, :text, null: false
      add :user_id, references(:users, on_delete: :delete_all)
      add :post_id, references(:posts, on_delete: :delete_all)

      timestamps()
    end
    create index(:comments, [:user_id])
    create index(:comments, [:post_id])

  end
end
