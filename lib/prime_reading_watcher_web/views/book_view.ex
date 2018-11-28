defmodule PrimeReadingWatcherWeb.BookView do
  use PrimeReadingWatcherWeb, :view
  alias PrimeReadingWatcherWeb.BookView

  def render("index.json", %{books: books}) do
    %{data: render_many(books, BookView, "book.json")}
  end

  def render("show.json", %{book: book}) do
    %{data: render_one(book, BookView, "book.json")}
  end

  def render("book.json", %{book: book}) do
    %{id: book.id,
      asin: book.asin,
      title: book.title,
      add_date: book.add_date,
      update_date: book.update_date}
  end
end
