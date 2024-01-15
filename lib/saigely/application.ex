defmodule Saigely.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SaigelyWeb.Telemetry,
      # Start the Ecto repository
      Saigely.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Saigely.PubSub},
      # Start Finch
      {Finch, name: Saigely.Finch},
      # Start the Endpoint (http/https)
      SaigelyWeb.Endpoint,
      # Start AI stuff
      Saigely.CharacterSupervisor,
      Saigely.Agents.Gatherer,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Saigely.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SaigelyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
