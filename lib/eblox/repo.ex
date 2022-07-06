defmodule Eblox.Repo do
  use Ecto.Repo,
    otp_app: :eblox,
    adapter: Ecto.Adapters.Postgres
end
