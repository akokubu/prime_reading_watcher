defmodule PrimeReadingWatcher.Catalogs.Book do
  use Ecto.Schema
  import Ecto.Changeset


  schema "books" do
    field :add_date, :date
    field :asin, :string
    field :title, :string
    field :update_date, :date

    timestamps()
  end

  @doc false
  def changeset(book, attrs) do
    book
    |> cast(attrs, [:asin, :title, :add_date, :update_date])
    |> validate_required([:asin, :add_date, :update_date])
  end
end
