defmodule RedditClone.Repo.Migrations.AddNestedPostComments do
  use Ecto.Migration

  def change do
    alter table(:comments) do
      add :parent_comment_id, references(:comments, on_delete: :nothing)
    end
  end
end
