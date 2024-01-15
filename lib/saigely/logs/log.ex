defmodule Saigely.Logs.Log do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "logs" do
    field :emoji, :string
    field :event, :string
    field :message, :string
    belongs_to(:character, Saigely.Characters.Character)

    timestamps()
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [:event, :message, :character_id, :emoji])
    |> validate_required([:event, :message])
  end
end
