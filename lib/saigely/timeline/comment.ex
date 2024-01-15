defmodule Saigely.Timeline.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "comments" do
    field :body, :string
    belongs_to(:character, Saigely.Characters.Character)
    belongs_to(:post, Saigely.Timeline.Post)

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:body, :character_id, :post_id])
    |> validate_required([:body])
  end
end
