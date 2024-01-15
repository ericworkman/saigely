defmodule SaigelyWeb.LogsComponent do
  use SaigelyWeb, :live_component

  def render_post_link(text) do
    regex = ~r/post:(?<id>[a-f0-9\-]+)/

    replaced =
      Regex.replace(regex, text, fn _, id ->
        "<a class=\"font-bold hover:underline\" href=\"/posts/#{id}\">post</a>"
      end)

    Phoenix.HTML.raw(replaced)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-dvh overflow-y-scroll">
      <div class="-mx-4 -my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
        <div class="inline-block min-w-full py-2 align-middle sm:px-6 lg:px-8">
          <table class="min-w-full divide-y divide-gray-300">
            <thead>
              <tr>
                <th
                  :if={@show_names}
                  scope="col"
                  class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-0"
                >
                  Character
                </th>
                <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900"></th>
                <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                  Monologue
                </th>
                <th scope="col" class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">
                  Time
                </th>
              </tr>
            </thead>
            <tbody id={@id} phx-update="stream" class="divide-y divide-gray-200 bg-white">
              <tr :for={{id, log} <- @logs} id={id}>
                <td :if={@show_names} class="whitespace-nowrap py-5 pl-4 pr-3 text-sm sm:pl-0">
                  <.link class="flex items-center" navigate={"/characters/#{log.character.username}"}>
                    <div class="h-11 w-11 flex-shrink-0">
                      <img class="h-11 w-11 rounded-full" src={log.character.avatar} alt="" />
                    </div>
                    <div class="ml-4">
                      <div class="font-medium text-gray-900">
                        <%= log.character.name %>
                      </div>
                      <div class="mt-1 text-gray-500">@<%= log.character.username %></div>
                    </div>
                  </.link>
                </td>
                <td class="px-3 py-5 text-xl text-gray-500">
                  <div class="text-gray-900"><%= log.emoji %></div>
                </td>
                <td class="px-3 py-5 text-xs text-gray-400 italic">
                  <div class="text-gray-900"><%= render_post_link(log.message) %></div>
                </td>
                <td class="whitespace-nowrap px-3 py-5 text-sm text-gray-500">
                  <%= Timex.from_now(log.inserted_at) %>
                </td>
              </tr>
              <!-- More people... -->
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end
end
