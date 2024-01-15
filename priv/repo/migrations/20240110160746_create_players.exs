defmodule Saigely.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create table(:characters, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :avatar, :text
      add :username, :string
      add :role, :text
      add :desire, :text
      add :vibe, :text
      add :pid, :string

      timestamps()
    end
  end
end
