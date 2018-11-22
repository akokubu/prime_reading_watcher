defmodule PrimeReadingWatcher.Repo do
  use Ecto.Repo,
    otp_app: :prime_reading_watcher,
    adapter: Ecto.Adapters.Postgres
end
