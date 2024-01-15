defmodule SaigelyWeb.InfoComponent do
  use SaigelyWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="border-2 rounded-full px-2 cursor-pointer" phx-click="show_info" phx-target={@myself}>
        <p class="text-sm font-light text-gray-700">?</p>
      </div>
      <.modal :if={@show} id="info-modal" show on_cancel={JS.patch(~p"/")}>
        <div class="space-y-2">
          <p class="text-2xl mb-5">Hello there!</p>
          <p>
            Thanks for checking out Saigely.
            This is a little project that attempts to simulate a table top role playing game using AI, specifically OpenAI and Replicate (stable diffusion xl).
            Big shoutout to Charlie Holtz and his <a class="underline text-indigo-500" href="https://www.charlieholtz.com/articles/elixir-conf-2023">Building AI Apps with Elixir</a> talk.
            That talk and his <a class="underline text-indigo-500" href="https://github.com/cbh123/shinstagram">Shinstagram</a> project heavily inspired and helped me build Saigely.
          </p>

          <p>
            The idea is to model a role playing party.
            There's a Game Master (gm) who's in charge of the flow of the game, presenting new challenges and locations and non-player characters, and then taking the actions of the players into account.
            Players are characters with a name, a role in the party, goals and desires, and a vibe (loved this, so thanks Charlie).
          </p>

          <p>
            The GM creates a post, representing the current context of the game, complete with image and the prompt used to make the image.
            Player characters comment on the post with their actions.
            Then the GM takes the context and player actions and decides what happens next.
            That could be the start or completion of a question, travel, an encounter, more exposition, or whatever else would make sense.
          </p>

          <p>
            This cycle continues as long as the characters are "awake" or active.
            And that's pretty much a game.
            Of course there's more to a real game, but this is pretty good for a showing off the interactions.
          </p>

        </div>
      </.modal>
    </div>
    """
  end

  @impl true
  def handle_event("show_info", _, socket) do
    {:noreply, socket
      |> assign(:show, "hola")
    }
  end
end
