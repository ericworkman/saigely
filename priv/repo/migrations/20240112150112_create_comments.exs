defmodule Saigely.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :body, :text
      add :character_id, references(:characters, on_delete: :nothing, type: :binary_id)
      add :post_id, references(:posts, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:comments, [:character_id])
    create index(:comments, [:post_id])
  end
end
