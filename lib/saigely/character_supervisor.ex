defmodule Saigely.CharacterSupervisor do
  @moduledoc """
  Keep track of the awake characters
  """
  use DynamicSupervisor

  alias Saigely.Characters

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :no_args, name: CharacterSupervisor)
  end

  def init(:no_args) do
    # TODO: safe as a single server, but not in a cluster
    Characters.reset_all_pids()

    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def add_character(%{duty: :gm} = character) do
    {:ok, pid} = DynamicSupervisor.start_child(CharacterSupervisor, {Saigely.Agents.GameRunner, character})
    Characters.update_character(character, %{pid: inspect(pid)})
  end

  def add_character(%{duty: :player} = character) do
    {:ok, pid} = DynamicSupervisor.start_child(CharacterSupervisor, {Saigely.Agents.Character, character})
    Characters.update_character(character, %{pid: inspect(pid)})
  end
end
