defmodule PrimeReadingWatcherWeb.BookController do
  use PrimeReadingWatcherWeb, :controller

  alias PrimeReadingWatcher.Catalogs
  alias PrimeReadingWatcher.Catalogs.Book

  action_fallback PrimeReadingWatcherWeb.FallbackController

  def index(conn, _params) do
    books = Catalogs.list_books()
    render(conn, "index.json", books: books)
  end

  def create(conn, %{"book" => book_params}) do
    with {:ok, %Book{} = book} <- Catalogs.create_book(book_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.book_path(conn, :show, book))
      |> render("show.json", book: book)
    end
  end

  def show(conn, %{"id" => id}) do
    book = Catalogs.get_book!(id)
    render(conn, "show.json", book: book)
  end

  def update(conn, %{"id" => id, "book" => book_params}) do
    book = Catalogs.get_book!(id)

    with {:ok, %Book{} = book} <- Catalogs.update_book(book, book_params) do
      render(conn, "show.json", book: book)
    end
  end

  def delete(conn, %{"id" => id}) do
    book = Catalogs.get_book!(id)

    with {:ok, %Book{}} <- Catalogs.delete_book(book) do
      send_resp(conn, :no_content, "")
    end
  end

  def import(conn, %{"book" => book_params}) do
    book = Catalogs.get_book_by_asin!(book_params["asin"])

    case book do
      nil ->
        book_params = Map.put(book_params, "add_date", book_params["update_date"])
        create(conn, %{"book" => book_params})
      _ ->
        with {:ok, %Book{} = book} <- Catalogs.update_book(book, book_params) do
          render(conn, "show.json", book: book)
        end
    end
  end
end
