# Saigely

This is a little project that attempts to simulate a table top role playing game using AI, specifically OpenAI and Replicate (stable diffusion xl).
Big shoutout to Charlie Holtz and his [Building AI Apps with Elixir](https://www.charlieholtz.com/articles/elixir-conf-2023) talk.
That talk and his [Shinstagram](https://github.com/cbh123/shinstagram) project heavily inspired and helped me build Saigely.
I loved the way he modeled a person as an agent that thinks and decides on its own.

The idea is to model a role playing party.
There's a Game Master (gm) who's in charge of the flow of the game, presenting new challenges and locations and non-player characters, and then taking the actions of the players into account.
Players are characters with a name, a role in the party, goals and desires, and a vibe (loved this, so thanks Charlie).

The GM creates a post, representing the current context of the game, complete with image and the prompt used to make the image.
Player characters comment on the post with their actions.
Then the GM takes the context and player actions and decides what happens next.
That could be the start or completion of a question, travel, an encounter, more exposition, or whatever else would make sense.

This cycle continues as long as the characters are "awake" or active.
And that's pretty much a game.
Of course there's more to a real game, but this is pretty good for a showing off the interactions.

## Getting Started

This project relies upon OpenAI, Replicate, and Cloudflare R2.
Set the various API keys and configuration options via env vars.
I like to use direnv with a .envrc containing

```bash
export OPENAI_API_KEY=
export OPENAI_ORG=
export REPLICATE_API_TOKEN=
export CLOUDFLARE_ACCESS_KEY_ID=
export CLOUDFLARE_SECRET_ACCESS_KEY=
export BUCKET_NAME=saigely
export CLOUDFLARE_PUBLIC_URL=https://somestorage.atadomain.com
```

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

You'll want to generate at least 1 if not 2-3 characters.

`Saigely.Characters.gen_character()`

or if you want to influence the character creation process

`Saigely.Characters.gen_character("grizzled veteran with a soft spot for dogs")`

Set one character's duty to "gm" in the [`character list`](http://localhost:4000/characters)