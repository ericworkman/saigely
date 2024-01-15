defmodule SaigelyWeb.CharacterLive.Show do
  use SaigelyWeb, :live_view

  alias Saigely.Characters

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"username" => username}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:character, Characters.get_character_by_username!(username))}
  end

  defp page_title(:show), do: "Show Character"
  defp page_title(:edit), do: "Edit Character"
end
