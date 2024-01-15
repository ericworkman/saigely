defmodule Saigely.CharactersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Saigely.Characters` context.
  """

  @doc """
  Generate a character.
  """
  def character_fixture(attrs \\ %{}) do
    {:ok, character} =
      attrs
      |> Enum.into(%{
        avatar: "some avatar",
        name: "some name",
        pid: "some pid",
        summary: "some summary",
        username: "some username",
        vibe: "some vibe"
      })
      |> Saigely.Characters.create_character()

    character
  end
end
