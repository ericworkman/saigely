defmodule Saigely.Agents.Gatherer do
  @moduledoc """
  """
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: Gatherer)
  end

  def init(state) do
    Phoenix.PubSub.subscribe(Saigely.PubSub, "management")
    {:ok, state}
  end

  def handle_info(:wake_everyone, state) do
    Saigely.Characters.list_sleeping_characters()
    |> Enum.each(fn character -> Saigely.CharacterSupervisor.add_character(character) end)

    {:noreply, state}
  end
end
