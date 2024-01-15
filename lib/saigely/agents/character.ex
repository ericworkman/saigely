defmodule Saigely.Agents.Character do
  @moduledoc """
  """
  use GenServer, restart: :transient

  import AI
  import Saigely.Utils
  alias Saigely.{Characters, Timeline}
  require Logger

  @channel "feed"
  @thinking_time 10_000
  @model "gpt-3.5-turbo"

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
    broadcast({:thought, "🌶️", "I'm deciding what action to take"}, character)

    for post <- Timeline.list_recent_posts(1) do
      evaluate(character, post)
      |> handle_decision()
    end

    broadcast({:thought, "✅", "I've completed my turn"}, character)
    Process.send_after(self(), :think, @thinking_time * 2)
    {:noreply, %{state | last_action: :think}}
  end

  def handle_info({"character_activity", _, _}, socket) do
    {:noreply, socket}
  end

  # 🗣️ The voice of the agent
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

  defp evaluate(character, post) do
    broadcast({:thought, "👀", "I'm evaluating post:#{post.id}"}, character)

    can_comment? = !Enum.any?(post.comments, &(&1.character_id == character.id))

    if can_comment? do
      {:ok, result} =
        ~l"""
        model: #{@model}
        system: You are role playing as a character in an RPG
        Here's some information about you:
        - Your name is #{character.name}.
        - Your role is #{character.role}.
        - Your desire is #{character.desire}.
        - Your vibe is #{character.vibe}.

        Here's some information about the scene:
        - The scene is #{post.photo_prompt}.
        - You are at #{post.location}.

        Keep the explanation short.
        Answer in the format <decision>;;<explanation-for-why>

        user: What does your character choose to do?
        """
        |> chat_completion()

      [decision, explanation] = String.split(result, ";;")
      {post, character, decision, explanation}
    else
      {post, character, "skip", "I've already commented on this post"}
    end
  end


  defp handle_decision({post, character, "skip", explanation}) do
    broadcast(
      {:thought, "💭", "I want to skip post:#{post.id} because '#{explanation}'"},
      character
    )
  end
  defp handle_decision({post, character, decision, explanation}) do
    broadcast(
      {:thought, "💭", "I want to #{decision} on post:#{post.id} because '#{explanation}'"},
      character
    )

    {:ok, _comment} = Timeline.create_comment(character, post, %{body: decision})
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
end
