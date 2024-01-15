defmodule Saigely.Repo do
  use Ecto.Repo,
    otp_app: :saigely,
    adapter: Ecto.Adapters.Postgres
end
