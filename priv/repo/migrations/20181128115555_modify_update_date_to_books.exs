defmodule PrimeReadingWatcher.Repo.Migrations.ModifyUpdateDateToBooks do
  use Ecto.Migration

  def change do
    alter table(:books) do
      modify :update_date, :date
    end
  end
end
