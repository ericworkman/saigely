defmodule Saigely.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "posts" do
    field :caption, :string
    field :location, :string
    field :photo, :string
    field :photo_prompt, :string
    belongs_to(:character, Saigely.Characters.Character)
    has_many(:comments, Saigely.Timeline.Comment)

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:caption, :photo, :photo_prompt, :character_id, :location])
    |> validate_required([])
  end
end
