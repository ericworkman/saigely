defmodule Saigely.Repo.Migrations.AddDutyToCharacter do
  use Ecto.Migration

  def change do
    alter table(:characters) do
      add :duty, :string
    end
  end
end
