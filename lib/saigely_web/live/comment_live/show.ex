defmodule SaigelyWeb.CommentLive.Show do
  use SaigelyWeb, :live_view

  alias Saigely.Timeline

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:comment, Timeline.get_comment!(id))}
  end

  defp page_title(:show), do: "Show Comment"
  defp page_title(:edit), do: "Edit Comment"
end
