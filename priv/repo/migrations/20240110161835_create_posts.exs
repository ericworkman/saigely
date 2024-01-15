defmodule Saigely.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :caption, :text
      add :photo, :text
      add :photo_prompt, :text
      add :location, :text
      add :character_id, references(:characters, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:posts, [:character_id])
  end
end
