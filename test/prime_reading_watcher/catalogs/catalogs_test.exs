defmodule PrimeReadingWatcher.CatalogsTest do
  use PrimeReadingWatcher.DataCase

  alias PrimeReadingWatcher.Catalogs

  describe "books" do
    alias PrimeReadingWatcher.Catalogs.Book

    @valid_attrs %{add_date: ~D[2010-04-17], asin: "some asin", title: "some title", update_date: ~N[2010-04-17 14:00:00]}
    @update_attrs %{add_date: ~D[2011-05-18], asin: "some updated asin", title: "some updated title", update_date: ~N[2011-05-18 15:01:01]}
    @invalid_attrs %{add_date: nil, asin: nil, title: nil, update_date: nil}

    def book_fixture(attrs \\ %{}) do
      {:ok, book} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Catalogs.create_book()

      book
    end

    test "list_books/0 returns all books" do
      book = book_fixture()
      assert Catalogs.list_books() == [book]
    end

    test "get_book!/1 returns the book with given id" do
      book = book_fixture()
      assert Catalogs.get_book!(book.id) == book
    end

    test "create_book/1 with valid data creates a book" do
      assert {:ok, %Book{} = book} = Catalogs.create_book(@valid_attrs)
      assert book.add_date == ~D[2010-04-17]
      assert book.asin == "some asin"
      assert book.title == "some title"
      assert book.update_date == ~N[2010-04-17 14:00:00]
    end

    test "create_book/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Catalogs.create_book(@invalid_attrs)
    end

    test "update_book/2 with valid data updates the book" do
      book = book_fixture()
      assert {:ok, %Book{} = book} = Catalogs.update_book(book, @update_attrs)
      assert book.add_date == ~D[2011-05-18]
      assert book.asin == "some updated asin"
      assert book.title == "some updated title"
      assert book.update_date == ~N[2011-05-18 15:01:01]
    end

    test "update_book/2 with invalid data returns error changeset" do
      book = book_fixture()
      assert {:error, %Ecto.Changeset{}} = Catalogs.update_book(book, @invalid_attrs)
      assert book == Catalogs.get_book!(book.id)
    end

    test "delete_book/1 deletes the book" do
      book = book_fixture()
      assert {:ok, %Book{}} = Catalogs.delete_book(book)
      assert_raise Ecto.NoResultsError, fn -> Catalogs.get_book!(book.id) end
    end

    test "change_book/1 returns a book changeset" do
      book = book_fixture()
      assert %Ecto.Changeset{} = Catalogs.change_book(book)
    end
  end
end
