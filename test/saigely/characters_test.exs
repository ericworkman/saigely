defmodule Saigely.CharactersTest do
  use Saigely.DataCase

  alias Saigely.Characters

  describe "characters" do
    alias Saigely.Characters.Character

    import Saigely.CharactersFixtures

    @invalid_attrs %{avatar: nil, name: nil, pid: nil, role: nil, username: nil, vibe: nil}

    test "list_characters/0 returns all characters" do
      character = character_fixture()
      assert Characters.list_characters() == [character]
    end

    test "get_character!/1 returns the character with given id" do
      character = character_fixture()
      assert Characters.get_character!(character.id) == character
    end

    test "create_character/1 with valid data creates a character" do
      valid_attrs = %{avatar: "some avatar", name: "some name", pid: "some pid", role: "some role", username: "some username", vibe: "some vibe"}

      assert {:ok, %Character{} = character} = Characters.create_character(valid_attrs)
      assert character.avatar == "some avatar"
      assert character.name == "some name"
      assert character.pid == "some pid"
      assert character.role == "some role"
      assert character.username == "some username"
      assert character.vibe == "some vibe"
    end

    test "create_character/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Characters.create_character(@invalid_attrs)
    end

    test "update_character/2 with valid data updates the character" do
      character = character_fixture()
      update_attrs = %{avatar: "some updated avatar", name: "some updated name", pid: "some updated pid", role: "some updated role", username: "some updated username", vibe: "some updated vibe"}

      assert {:ok, %Character{} = character} = Characters.update_character(character, update_attrs)
      assert character.avatar == "some updated avatar"
      assert character.name == "some updated name"
      assert character.pid == "some updated pid"
      assert character.role == "some updated role"
      assert character.username == "some updated username"
      assert character.vibe == "some updated vibe"
    end

    test "update_character/2 with invalid data returns error changeset" do
      character = character_fixture()
      assert {:error, %Ecto.Changeset{}} = Characters.update_character(character, @invalid_attrs)
      assert character == Characters.get_character!(character.id)
    end

    test "delete_character/1 deletes the character" do
      character = character_fixture()
      assert {:ok, %Character{}} = Characters.delete_character(character)
      assert_raise Ecto.NoResultsError, fn -> Characters.get_character!(character.id) end
    end

    test "change_character/1 returns a character changeset" do
      character = character_fixture()
      assert %Ecto.Changeset{} = Characters.change_character(character)
    end
  end
end
