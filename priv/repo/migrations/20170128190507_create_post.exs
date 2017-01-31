defmodule RedditClone.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string, null: false
      add :text, :text
      add :url, :text
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
    create index(:posts, [:user_id])

  end
end
