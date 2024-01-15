defmodule SaigelyWeb.PostLive.Index do
  use SaigelyWeb, :live_view

  alias Saigely.{Logs, Characters, Timeline}
  alias Saigely.Timeline.Post

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Timeline.subscribe()
      Phoenix.PubSub.subscribe(Saigely.PubSub, "feed")
    end

    {:ok,
     socket
     |> stream(:posts, Timeline.list_recent_posts(10))
     |> stream(:logs, Logs.list_recent_logs(50))}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Post")
    |> assign(:post, Timeline.get_post!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Post")
    |> assign(:post, %Post{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Posts")
    |> assign(:post, nil)
  end

  @impl true
  def handle_info({SaigelyWeb.PostLive.FormComponent, {:saved, post}}, socket) do
    {:noreply, stream_insert(socket, :posts, post)}
  end

  def handle_info({"character_activity", _event, log}, socket) do
    {:noreply, socket |> stream_insert(:logs, log, at: 0)}
  end

  def handle_info({:post_created, post}, socket) do
    {:noreply, socket |> stream_insert(:posts, post, at: 0)}
  end

  def handle_info({:post_updated, post}, socket) do
    {:noreply, socket |> stream_insert(:posts, post)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Timeline.get_post!(id)
    {:ok, _} = Timeline.delete_post(post)

    {:noreply, stream_delete(socket, :posts, post)}
  end

  def handle_event("post", _, socket) do
    {:noreply, socket}
  end

  def handle_event("start-encounter", _, socket) do
    Phoenix.PubSub.broadcast(Saigely.PubSub, "management", :wake_everyone)
    {:noreply, socket}
  end

  def handle_event("sleep", _, socket) do
    Characters.list_awake_characters()
    |> Enum.map(fn character -> Saigely.Agents.Character.shutdown_character(character.pid) end)
    Characters.reset_all_pids()

    {:noreply, socket}
  end
end
