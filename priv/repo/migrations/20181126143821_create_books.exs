defmodule PrimeReadingWatcher.Repo.Migrations.CreateBooks do
  use Ecto.Migration

  def change do
    create table(:books) do
      add :asin, :string
      add :title, :string
      add :add_date, :date
      add :update_date, :naive_datetime

      timestamps()
    end

  end
end
