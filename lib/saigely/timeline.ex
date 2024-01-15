defmodule Saigely.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false
  alias Saigely.Repo
  import AI
  import Saigely.Utils

  alias Saigely.Characters.Character
  alias Saigely.Timeline.Post

  require Logger

  @model "gpt-4-1106-preview"

  def subscribe do
    Phoenix.PubSub.subscribe(Saigely.PubSub, "posts")
  end

  defp broadcast({:error, _reason} = error, _), do: error

  defp broadcast({:ok, post}, event) do
    Phoenix.PubSub.broadcast(
      Saigely.PubSub,
      "posts",
      {event, post}
    )

    {:ok, post}
  end

  def log(message) do
    Logger.info(message)
    {:ok, log} = Saigely.Logs.create_log(%{event: "characters", status: message})

    Phoenix.PubSub.broadcast(Saigely.PubSub, "characters", {"characters", log})
  end

  @doc """
  Gathers all the relevant info from a character and generates a text-to-image prompt,
  as well as a caption for the photo.

  Returns {:ok, image_prompt}.

  ## Examples

      iex> create_image_prompt(character)
      "A futuristic digital artwork with clean lines, neon glows, and dark background featuring bright, colorful accents."
  """
  def gen_image_prompt(%Character{username: username, role: role, desire: desire, vibe: vibe}) do
    ~l"""
    model: #{@model}
    system: You are an expert at creating text-to-image prompts and running role playing games. Don't include the word 'caption' in your output.
    user: Username: #{username} Role: #{role} Desire: #{desire} Vibe: #{vibe}
    """
    |> chat_completion()
  end

  def gen_image_prompt_for_scene(location, desc) do
    ~l"""
    model: #{@model}
    system: You are an expert at creating text-to-image prompts and running role playing games. Include detail about the character that's talking to them. Don't include the word 'caption' or 'location' in your output. Speak as if you are the one introducing the scene to the party. Keep the output to 4 sentences.
    user: I need a scene with a hook for an RPG party. The party is at
    #{location}
    #{desc}
    """
    |> chat_completion()
  end

  @doc """
  Generates the caption for the image.

  Returns {:ok, caption}
  """
  def gen_caption(
        image_prompt,
        %Character{username: username, role: role, desire: desire, vibe: vibe}
      ) do
    ~l"""
    model: #{@model}
    system: You are an expert at creating captions for social media posts. The following character is posting a photo to a social network and we need a caption for the photo. Can you output the caption? It should match the vibe of the character. Don't include the word 'caption' in your output.
    user: Username: #{username} Role: #{role} Desire: #{desire} Vibe: #{vibe}. Photo description: #{image_prompt}
    """
    |> chat_completion()
  end

  def gen_location() do
    {:ok, result} = ~l"""
    model: #{@model}
    system: You are an expert at creating text-to-image prompts and running role playing games. Include detail about the location the party is in. Describe it as if you are the one introducing the scene to the party. Keep the description to 3 sentences or fewer.
    Answer in the format <location>;;<description>
    user: I need a location for the start of an adventure for a new party.
    """
    |> chat_completion()
    [location, description] = String.split(result, ";;")
    {:ok, location, description}
  end

  def gen_location_prompt(name) do
    {:ok, result} = ~l"""
    model: #{@model}
    system: You are an expert at creating text-to-image prompts and running role playing games. Include detail about the location the party is in. Describe it as if you are the one introducing the scene to the party. Keep the description to 3 sentences or fewer.
    user: Describe the location "#{name}"
    """
    |> chat_completion()
    {:ok, name, result}
  end

  @doc """
  Given a character, generate a post.
  """
  def gen_post(character) do
    with {:ok, location, location_desc} <- gen_location(),
         {:ok, image_prompt} <- gen_image_prompt_for_scene(location, location_desc),
         #{:ok, caption} <- gen_caption(image_prompt, character),
         {:ok, image_url} <- gen_image(image_prompt) do
      create_post(character, %{
        photo: image_url,
        photo_prompt: image_prompt,
        caption: image_prompt,
        location: location
      })
    else
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(Post)
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id) |> Repo.preload([:character, [comments: :character]])

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(%Character{} = character, attrs \\ %{}) do
    {:ok, post} = %Post{}
    |> Post.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:character, character)
    |> Repo.insert()

    post = get_post!(post.id)
    broadcast({:ok, post}, :post_created)
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def list_posts_by_character(character) do
    Repo.all(from(p in Post, where: p.character_id == ^character.id, order_by: [desc: p.inserted_at]))
  end

  def list_posts_by_character(character, limit) do
    Repo.all(
      from(p in Post,
        where: p.character_id == ^character.id,
        order_by: [desc: p.inserted_at],
        limit: ^limit
      )
    )
    |> Repo.preload([:character])
  end

  def list_recent_posts(limit) do
    from(p in Post, order_by: [desc: p.inserted_at], limit: ^limit)
    |> Repo.all()
    |> Repo.preload([:character, [comments: :character]])
  end

  def list_recent_player_posts(limit) do
    from(
      p in Post,
      join: c in Character, on: p.character_id == c.id,
      where: c.duty != :gm,
      order_by: [desc: p.inserted_at],
      limit: ^limit
    )
    |> Repo.all()
    |> Repo.preload([:character])
  end

  def get_most_recent_post_by_gm() do
    from(
      p in Post,
      join: c in Character, on: p.character_id == c.id,
      where: c.duty == :gm,
      order_by: [desc: p.inserted_at],
      preload: [:comments],
      limit: 1
    )
    |> Repo.one()
  end

  alias Saigely.Timeline.Comment

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments do
    Repo.all(Comment)
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Repo.insert()
  end

  def create_comment(%Character{} = character, %Post{} = post, attrs \\ %{}) do
    {:ok, comment} = %Comment{}
    |> Comment.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:character, character)
    |> Ecto.Changeset.put_assoc(:post, post)
    |> Repo.insert()

    post = get_post!(post.id)
    broadcast({:ok, post}, :post_updated)
    {:ok, comment}
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{data: %Comment{}}

  """
  def change_comment(%Comment{} = comment, attrs \\ %{}) do
    Comment.changeset(comment, attrs)
  end
end
