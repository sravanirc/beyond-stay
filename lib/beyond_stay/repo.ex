defmodule BeyondStay.Repo do
  use Ecto.Repo,
    otp_app: :beyond_stay,
    adapter: Ecto.Adapters.Postgres
end
