defmodule Saigely.Agents.GameRunner do
  @moduledoc """
  """
  use GenServer, restart: :transient

  import AI
  import Saigely.Utils
  alias Saigely.{Characters, Timeline}
  require Logger

  @channel "feed"
  @thinking_time 10_000
  @model "gpt-4-1106-preview"

  def start_link(character) do
    {:ok, pid} = GenServer.start_link(__MODULE__, %{character: character, last_action: nil})
    {:ok, pid}
  end

  def init(state) do
    Phoenix.PubSub.subscribe(Saigely.PubSub, @channel)
    broadcast({:thought, "🌅", "I'm waking up!"}, state.character)

    Process.send_after(self(), :think, 3000)
    {:ok, state}
  end

  def handle_info(:sleep, %{character: character} = state) do
    broadcast({:action, "💤", "I'm going back to sleep..."}, character)
    Saigely.Characters.update_character(character, %{pid: nil})

    {:stop, :normal, state}
  end

  def handle_info(:think, %{character: character} = state) do
    broadcast({:thought, "🔎", "I'm deciding what's next for the characters"}, character)

    previous_decision = Timeline.get_most_recent_post_by_gm()

    ready = is_nil(previous_decision) || length(previous_decision.comments) >= 2

    if ready do
      evaluate(character, previous_decision)
      |> handle_next(state)
    else
      broadcast({:thought, "⏱", "I'm waiting for the players"}, character)
      Process.send_after(self(), :think, @thinking_time)
      {:noreply, state}
    end

  end

  def handle_info({"character_activity", _, _}, socket) do
    {:noreply, socket}
  end

  defp broadcast({event, emoji, message}, character) do
    log =
      Saigely.Logs.create_log!(%{
        event: event |> Atom.to_string(),
        message: message,
        character_id: character.id,
        emoji: emoji
      })

    Phoenix.PubSub.broadcast(Saigely.PubSub, @channel, {"character_activity", event, log})
  end

  defp broadcast({:ok, text}, {event, emoji, message}, character) do
    broadcast({event, emoji, message}, character)
    {:ok, text}
  end

  defp evaluate(character, nil) do
    broadcast({:thought, "🪝", "I'm figuring out a hook"}, character)
    {:ok, result} =
      ~l"""
      model: #{@model}
      system: You are running a role playing game as the dungeon master.

      This is a brand new party, and they need to meet somewhere and get a hook into a story line.
      Be descriptive but short in your setup, and restrict the output to no more than 5 sentences.
      Answer in the format <location>;;<setup>

      user: Where are the characters and what's the triggering hook?
      """
      |> chat_completion()

    [location, setup] = String.split(result, ";;")

    {nil, character, "start-adventure", setup, location}

  end
  defp evaluate(character, post) do
    broadcast({:thought, "👀", "I'm figuring out what's next from post:#{post.id}"}, character)
    {:ok, result} =
      ~l"""
      model: #{@model}
      system: You are running a role playing game as the dungeon master.

      Here's some information about the scene:
      #{post.photo_prompt}.

      The party is at #{post.location}.

      The party has decided to:
      #{post.comments |> Enum.map(& &1.body) |> Enum.join("\n- ") }

      Your decision options are: [travel, start-encounter, end-encounter, start-quest, finish-quest, continue]. Keep the explanation short.
      Answer in the format <decision>;;<location>;;<explanation-for-why>

      user: What happens next in the story?
      """
      |> chat_completion()

    [decision, location, explanation] = String.split(result, ";;")
    {post, character, decision, explanation, location}
  end

  defp handle_next({post, character, decision, explanation, loc}, state) do
    broadcast(
      {:thought, "💭", "I guide the party to #{decision}"},
      character
    )

    {:ok, location, description} = if !is_nil(post) && loc == post.location do
      {:ok, post.location, post.photo_prompt}
    else
      gen_location(character, loc)
    end

    seed = "#{explanation}\n#{description}"

    with {:ok, image_prompt} <- gen_image_prompt(character, location, seed),
          {:ok, image_url} <- gen_image(image_prompt),
          {:ok, _post} <- create_post(character, image_url, image_prompt, explanation, location) do
      Process.send_after(self(), :think, @thinking_time)
      {:noreply, %{state | last_action: :post}}
    end
  end

  def shutdown_character(pid, timeout \\ 5_000)

  def shutdown_character(pid_string, timeout) when is_binary(pid_string) do
    pid =
      pid_string
      |> String.replace("#PID", "")
      |> String.to_charlist()
      |> :erlang.list_to_pid()

    shutdown(pid, timeout)
  end

  def shutdown_character(pid, timeout), do: shutdown(pid, timeout)

  defp shutdown(pid, timeout) do
    character = Characters.get_character_by_pid!(pid)
    broadcast({:action, "💤", "I'm going back to sleep..."}, character)
    try do
      GenServer.stop(pid, :normal, timeout)
    catch
      :exit, {:noproc, _} -> Logger.warning("PID #{inspect pid} missing")
    end
    Characters.update_character(character, %{pid: nil})
  end

  # helpers
  defp gen_image_prompt(character, location, location_desc) do
    Timeline.gen_image_prompt_for_scene(location, location_desc)
    |> broadcast({:thought, "🎨", "I picked a scene prompt"}, character)
  end

  defp gen_location(character, location) do
    {:ok, _, description} = Timeline.gen_location_prompt(location)
    broadcast({:action, "📸 ", "I made a photo of the location #{location}"}, character)
    {:ok, location, description}
  end

  defp create_post(character, image_url, image_prompt, caption, location) do
    character
    |> Timeline.create_post(%{
      photo: image_url,
      photo_prompt: image_prompt,
      caption: caption,
      location: location
    })
  end

end
