defmodule Saigely.Characters do
  @moduledoc """
  The Characters context.
  """

  import Ecto.Query, warn: false
  alias Saigely.Repo
  import AI

  alias Saigely.Characters.Character
  alias Saigely.Utils
  require Logger

  @model "gpt-4-1106-preview"

  def reset_all_pids do
    from(p in Character)
    |> Repo.update_all(set: [pid: nil])
  end

  def get_random_character() do
    from(p in Character, order_by: fragment("RANDOM()"), limit: 1) |> Repo.one()
  end

  def get_random_asleep_character() do
    from(p in Character, where: is_nil(p.pid), order_by: fragment("RANDOM()"), limit: 1)
    |> Repo.one()
  end

  @doc """
  Generates a character with AI.
  """
  def gen_character(hint \\ "") do
    Logger.info("Generating new character...")

    {:ok, character} =
      gen_character_desc(hint)
      |> decode_character_desc()
      |> create_character()

    {:ok, image} =
      character
      |> gen_character_photo_prompt()
      |> Utils.gen_image()

    character
    |> update_character(%{avatar: image})
  end

  @doc """
  Generate character photo prompt.
  """
  def gen_character_photo_prompt(%Character{username: username, role: role, desire: desire, vibe: vibe}) do
    ~l"""
    model: #{@model}
    system: You are an expert at creating text-to-image prompts. The following character needs a way of describing their profile picture. Can you output the text-to-image prompt? It should match the vibe of the character. Don't include the word 'caption' in your output.
    user: Username: #{username} Role: #{role} Desire: #{desire} Vibe: #{vibe}
    """
    |> OpenAI.chat_completion()
    |> Utils.parse_chat()
  end

  @doc """
  Generates a character description.
  """
  def gen_character_desc(hint) do
    ~l"""
    model: #{@model}
    system: You are an expert at role playing games. Answer only in the format specified. I'm creating a party for a role playing game that's in a high fantasy setting. Each character has a name, username, a role in the party, a desire they wish to accomplish, and a "vibe" that describes their preferred photo style. Follow the example.
    user: Can you generate me a character?
    #{hint}

    Example
    name: Lucas Lightbringer
    username: bringmethelight
    role: 🤺 Fighter and face
    desire: To bring happiness to the people by being king
    vibe: Regal - flourishes, lush fabrics, swords, purples and reds.
    """
    |> OpenAI.chat_completion()
    |> Utils.parse_chat()
  end

  @doc """
  Decodes the response from AI into a map

  iex> "Name: Jackson Redmane\nUsername: RedWizard\nRole: Wizard\n..."
  |> decode_character_desc()
  %{name: _, username: _, role: _, desire: _, vibe: _}

  """
  def decode_character_desc({:ok, content}) do
    content
    |> String.split("\n")
    |> Enum.map(&decode_line(&1))
    |> Enum.into(%{})
  end

  defp decode_line(line), do: line |> String.split(": ") |> decode_desc()
  defp decode_desc([key, value]), do: {key, String.trim(value)}
  defp decode_desc(_), do: {:skip, ""}

  def get_character_by_username!(username) do
    Repo.get_by!(Character, username: username)
  end

  def get_character_by_pid!(pid) do
    pid_string = inspect(pid)
    Repo.get_by!(Character, pid: pid_string)
  end

  @doc """
  Returns the list of characters.

  ## Examples

      iex> list_characters()
      [%Character{}, ...]

  """
  def list_characters do
    Repo.all(Character)
  end

  def list_awake_characters do
    from(p in Character, where: not is_nil(p.pid)) |> Repo.all()
  end

  def list_sleeping_characters do
    from(p in Character, where: is_nil(p.pid)) |> Repo.all()
  end

  @doc """
  Gets a single character.

  Raises `Ecto.NoResultsError` if the Character does not exist.

  ## Examples

      iex> get_character!(123)
      %Character{}

      iex> get_character!(456)
      ** (Ecto.NoResultsError)

  """
  def get_character!(id), do: Repo.get!(Character, id)

  @doc """
  Creates a character.

  ## Examples

      iex> create_character(%{field: value})
      {:ok, %Character{}}

      iex> create_character(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_character(attrs \\ %{}) do
    %Character{}
    |> Character.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a character.

  ## Examples

      iex> update_character(character, %{field: new_value})
      {:ok, %Character{}}

      iex> update_character(character, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_character(%Character{} = character, attrs) do
    character
    |> Character.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a character.

  ## Examples

      iex> delete_character(character)
      {:ok, %Character{}}

      iex> delete_character(character)
      {:error, %Ecto.Changeset{}}

  """
  def delete_character(%Character{} = character) do
    Repo.delete(character)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking character changes.

  ## Examples

      iex> change_character(character)
      %Ecto.Changeset{data: %Character{}}

  """
  def change_character(%Character{} = character, attrs \\ %{}) do
    Character.changeset(character, attrs)
  end
end
