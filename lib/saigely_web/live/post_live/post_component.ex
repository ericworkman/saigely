defmodule SaigelyWeb.PostLive.PostComponent do
  use SaigelyWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id={"post-component-#{@id}"} class="max-w-md mx-auto border-b pb-6 border-gray-300">
      <.link navigate={~p"/characters/#{@character.username}"} class="group block flex-shrink-0">
        <div class="flex items-center">
          <div>
            <img class="inline-block h-9 w-9 rounded-full" src={@character.avatar} alt="" />
          </div>
          <div class="ml-3">
            <p class="text-base font-semibold text-gray-900 group-hover:text-gray-700">
              <%= @character.username %>
              <span class="text-xs text-gray-500">• <%= Timex.from_now(@post.inserted_at) %></span>
            </p>
            <p class="text-xs font-medium text-gray-500"><%= @post.location %></p>
          </div>
        </div>
      </.link>
      <div class="mt-4">
        <.link navigate={~p"/posts/#{@post.id}"}>
          <img class="rounded-sm" src={@post.photo} alt={@post.photo_prompt} loading="lazy" />
        </.link>

        <%!-- Caption --%>
        <p :if={not is_nil(@post.caption)} class="text-base mt-2">
          <%= @post.caption |> String.replace("\"", "") %>
        </p>

        <p :if={not is_nil(@post.photo_prompt)} class="text-base mt-2">
          <%= @post.photo_prompt |> String.replace("\"", "") %>
        </p>

        <%!-- Comments --%>
        <ul class="mt-2">
          <%= for comment <- @post.comments do %>
            <li class="block">
              <.link
                class="hover:underline font-bold"
                navigate={~p"/characters/#{comment.character.username}"}
              >
                <%= comment.character.name %>
              </.link>
              <%= comment.body %>
            </li>
          <% end %>
        </ul>

      </div>
    </div>
    """
  end
end
