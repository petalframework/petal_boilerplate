defmodule PetalBoilerplate.Repo do
  use Ecto.Repo,
    otp_app: :petal_boilerplate,
    adapter: Ecto.Adapters.Postgres
end
