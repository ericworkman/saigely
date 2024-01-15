defmodule Saigely.TimelineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Saigely.Timeline` context.
  """

  import Saigely.CharactersFixtures

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    character = character_fixture()
    {:ok, post} =
      attrs
      |> Enum.into(%{
        caption: "some caption",
        location: "some location",
        photo: "some photo",
        photo_prompt: "some photo_prompt"
      })
      |> create_post(character)

    post
  end

  defp create_post(attrs, character), do: Saigely.Timeline.create_post(character, attrs)

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        body: "some body"
      })
      |> Saigely.Timeline.create_comment()

    comment
  end
end
