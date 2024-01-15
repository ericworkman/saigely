defmodule SaigelyWeb.CharacterLive.FormComponent do
  use SaigelyWeb, :live_component

  alias Saigely.Characters

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage character records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="character-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:avatar]} type="text" label="Avatar" />
        <.input field={@form[:username]} type="text" label="Username" />
        <.input field={@form[:role]} type="text" label="Role" />
        <.input field={@form[:desire]} type="text" label="Desire" />
        <.input field={@form[:vibe]} type="textarea" label="Vibe" />
        <.input field={@form[:duty]} type="select" label="Duty" options={["gm", "player"]}/>
        <:actions>
          <.button phx-disable-with="Saving...">Save Character</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{character: character} = assigns, socket) do
    changeset = Characters.change_character(character)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"character" => character_params}, socket) do
    changeset =
      socket.assigns.character
      |> Characters.change_character(character_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"character" => character_params}, socket) do
    save_character(socket, socket.assigns.action, character_params)
  end

  defp save_character(socket, :edit, character_params) do
    case Characters.update_character(socket.assigns.character, character_params) do
      {:ok, character} ->
        notify_parent({:saved, character})

        patch = if Map.has_key?(socket.assigns, :patch) do
          socket.assigns.patch
        else
          ~p"/characters/#{character.username}"
        end

        {:noreply,
         socket
         |> put_flash(:info, "Character updated successfully")
         |> push_patch(to: patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_character(socket, :new, character_params) do
    case Characters.create_character(character_params) do
      {:ok, character} ->
        notify_parent({:saved, character})

        patch = if Map.has_key?(socket.assigns, :patch) do
          socket.assigns.patch
        else
          ~p"/characters/#{character.username}"
        end

        {:noreply,
         socket
         |> put_flash(:info, "Character created successfully")
         |> push_patch(to: patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
