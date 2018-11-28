defmodule PrimeReadingWatcherWeb.BookControllerTest do
  use PrimeReadingWatcherWeb.ConnCase

  alias PrimeReadingWatcher.Catalogs
  alias PrimeReadingWatcher.Catalogs.Book

  @create_attrs %{
    add_date: ~D[2010-04-17],
    asin: "some asin",
    title: "some title",
    update_date: ~N[2010-04-17 14:00:00]
  }
  @update_attrs %{
    add_date: ~D[2011-05-18],
    asin: "some updated asin",
    title: "some updated title",
    update_date: ~N[2011-05-18 15:01:01]
  }
  @invalid_attrs %{add_date: nil, asin: nil, title: nil, update_date: nil}

  def fixture(:book) do
    {:ok, book} = Catalogs.create_book(@create_attrs)
    book
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all books", %{conn: conn} do
      conn = get(conn, Routes.book_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create book" do
    test "renders book when data is valid", %{conn: conn} do
      conn = post(conn, Routes.book_path(conn, :create), book: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.book_path(conn, :show, id))

      assert %{
               "id" => id,
               "add_date" => "2010-04-17",
               "asin" => "some asin",
               "title" => "some title",
               "update_date" => "2010-04-17T14:00:00"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.book_path(conn, :create), book: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update book" do
    setup [:create_book]

    test "renders book when data is valid", %{conn: conn, book: %Book{id: id} = book} do
      conn = put(conn, Routes.book_path(conn, :update, book), book: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.book_path(conn, :show, id))

      assert %{
               "id" => id,
               "add_date" => "2011-05-18",
               "asin" => "some updated asin",
               "title" => "some updated title",
               "update_date" => "2011-05-18T15:01:01"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, book: book} do
      conn = put(conn, Routes.book_path(conn, :update, book), book: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete book" do
    setup [:create_book]

    test "deletes chosen book", %{conn: conn, book: book} do
      conn = delete(conn, Routes.book_path(conn, :delete, book))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.book_path(conn, :show, book))
      end
    end
  end

  defp create_book(_) do
    book = fixture(:book)
    {:ok, book: book}
  end
end
