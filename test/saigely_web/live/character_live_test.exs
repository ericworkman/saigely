defmodule SaigelyWeb.CharacterLiveTest do
  use SaigelyWeb.ConnCase

  import Phoenix.LiveViewTest
  import Saigely.CharactersFixtures

  @create_attrs %{avatar: "some avatar", name: "some name", role: "some role", username: "some username", vibe: "some vibe"}
  @update_attrs %{avatar: "some updated avatar", name: "some updated name", role: "some updated role", username: "some updated username", vibe: "some updated vibe"}
  @invalid_attrs %{avatar: nil, name: nil,  role: nil, username: nil, vibe: nil}

  defp create_character(_) do
    character = character_fixture()
    %{character: character}
  end

  describe "Index" do
    setup [:create_character]

    test "lists all characters", %{conn: conn, character: character} do
      {:ok, _index_live, html} = live(conn, ~p"/characters")

      assert html =~ "Listing Characters"
      assert html =~ character.avatar
    end

    test "saves new character", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/characters")

      assert index_live |> element("a", "New Character") |> render_click() =~
               "New Character"

      assert_patch(index_live, ~p"/characters/new")

      assert index_live
             |> form("#character-form", character: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#character-form", character: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/characters")

      html = render(index_live)
      assert html =~ "Character created successfully"
      assert html =~ "some avatar"
    end

    test "updates character in listing", %{conn: conn, character: character} do
      {:ok, index_live, _html} = live(conn, ~p"/characters")

      assert index_live |> element("#characters-#{character.id} a", "Edit") |> render_click() =~
               "Edit Character"

      assert_patch(index_live, ~p"/characters/#{character.username}/edit")

      assert index_live
             |> form("#character-form", character: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#character-form", character: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/characters")

      html = render(index_live)
      assert html =~ "Character updated successfully"
      assert html =~ "some updated avatar"
    end

    test "deletes character in listing", %{conn: conn, character: character} do
      {:ok, index_live, _html} = live(conn, ~p"/characters")

      assert index_live |> element("#characters-#{character.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#characters-#{character.id}")
    end
  end

  describe "Show" do
    setup [:create_character]

    test "displays character", %{conn: conn, character: character} do
      {:ok, _show_live, html} = live(conn, ~p"/characters/#{character.username}")

      assert html =~ "Show Character"
      assert html =~ character.avatar
    end

    test "updates character within modal", %{conn: conn, character: character} do
      {:ok, show_live, _html} = live(conn, ~p"/characters/#{character.username}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Character"

      assert_patch(show_live, ~p"/characters/#{character.username}/show/edit")

      assert show_live
             |> form("#character-form", character: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#character-form", character: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/characters/#{@update_attrs.username}")

      html = render(show_live)
      assert html =~ "Character updated successfully"
      assert html =~ "some updated avatar"
    end
  end
end
