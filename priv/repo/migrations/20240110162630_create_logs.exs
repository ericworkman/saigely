defmodule Saigely.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:logs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :event, :text
      add :message, :text
      add :emoji, :text
      add :character_id, references(:characters, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:logs, [:character_id])
  end
end
