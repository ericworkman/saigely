defmodule Saigely.Characters.Character do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "characters" do
    field :avatar, :string
    field :name, :string
    field :pid, :string
    field :role, :string
    field :desire, :string
    field :username, :string
    field :vibe, :string
    field :duty, Ecto.Enum, values: [:gm, :player], default: :player

    timestamps()
  end

  @doc false
  def changeset(character, attrs) do
    character
    |> cast(attrs, [:name, :avatar, :username, :role, :desire, :vibe, :pid, :duty])
    |> validate_required([:name, :username])
    |> unique_constraint(:username)
  end
end
