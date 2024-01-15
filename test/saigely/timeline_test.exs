defmodule Saigely.TimelineTest do
  use Saigely.DataCase

  alias Saigely.Timeline

  import Saigely.CharactersFixtures

  describe "posts" do
    alias Saigely.Timeline.Post

    import Saigely.TimelineFixtures

    test "list_posts/0 returns all posts" do
      post = post_fixture()
      assert List.first(Timeline.list_posts()).id  == post.id
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Timeline.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      character = character_fixture()
      valid_attrs = %{caption: "some caption", location: "some location", photo: "some photo", photo_prompt: "some photo_prompt"}

      assert {:ok, %Post{} = post} = Timeline.create_post(character, valid_attrs)
      assert post.caption == "some caption"
      assert post.location == "some location"
      assert post.photo == "some photo"
      assert post.photo_prompt == "some photo_prompt"
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{caption: "some updated caption", location: "some updated location", photo: "some updated photo", photo_prompt: "some updated photo_prompt"}

      assert {:ok, %Post{} = post} = Timeline.update_post(post, update_attrs)
      assert post.caption == "some updated caption"
      assert post.location == "some updated location"
      assert post.photo == "some updated photo"
      assert post.photo_prompt == "some updated photo_prompt"
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Timeline.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Timeline.change_post(post)
    end
  end

  describe "comments" do
    alias Saigely.Timeline.Comment

    import Saigely.TimelineFixtures

    @invalid_attrs %{body: nil}

    test "list_comments/0 returns all comments" do
      comment = comment_fixture()
      assert Timeline.list_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      assert Timeline.get_comment!(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment" do
      valid_attrs = %{body: "some body"}

      assert {:ok, %Comment{} = comment} = Timeline.create_comment(valid_attrs)
      assert comment.body == "some body"
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_comment(@invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment" do
      comment = comment_fixture()
      update_attrs = %{body: "some updated body"}

      assert {:ok, %Comment{} = comment} = Timeline.update_comment(comment, update_attrs)
      assert comment.body == "some updated body"
    end

    test "update_comment/2 with invalid data returns error changeset" do
      comment = comment_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_comment(comment, @invalid_attrs)
      assert comment == Timeline.get_comment!(comment.id)
    end

    test "delete_comment/1 deletes the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{}} = Timeline.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()
      assert %Ecto.Changeset{} = Timeline.change_comment(comment)
    end
  end
end
