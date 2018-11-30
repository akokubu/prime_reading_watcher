defmodule PrimeReadingWatcherWeb.BookController do
  use PrimeReadingWatcherWeb, :controller

  alias PrimeReadingWatcher.Catalogs
  alias PrimeReadingWatcher.Catalogs.Book

  action_fallback PrimeReadingWatcherWeb.FallbackController

  require Record
  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl") 

  use Timex

  @key "AKIAIWLEHM3R4ASL6ERA"
  @sec "vJ2nmAH5pPDt7SMfgOdvTAYvv1P8SNyuT9xB6NYG"
  @tag "fuzzynavel0d-22"


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

  def updateTitle(conn, _params) do
    Catalogs.list_books_tltle_is_null
    |> Enum.chunk(10)
    |> Enum.map fn asins ->
      asins
      |> get_product
      |> Enum.map fn item ->
        book = Catalogs.get_book_by_asin!(item.asin)
        book_params = %{"title": item.title}

        Catalogs.update_book(book, book_params)
      end
      Process.sleep(1000)
    end
    send_resp(conn, :no_content, "")
  end

  def get_product asins do
    asin = Enum.join asins, ","

    url = "http://ecs.amazonaws.jp/onca/xml?Service=AWSECommerceService&AWSAccessKeyId=#{@key}&AssociateTag=#{@tag}&IdType=ASIN&ItemId=#{asin}&Operation=ItemLookup&ResponseGroup=ItemAttributes%2CItemIds"

    signed_url = url |> URI.parse |> timestamp |> sign
    IO.puts signed_url
    case HTTPoison.get! signed_url do
      %{status_code: 200, body: body} -> parse_response body
      %{status_code: code} -> IO.puts "error: #{code}"
    end
  end

  defp timestamp url do
    {:ok, now} = Timex.format(Timex.now, "{ISO:Extended:Z}")

    timestamped = url.query
    |> URI.decode_query
    |> Map.put_new("Timestamp", now)
    |> URI.encode_query

    Map.put url, :query, timestamped
  end

  defp sign url do
    ordered_query = url.query
    |> URI.decode_query
    |> Enum.sort
    |> URI.encode_query

    sig = :crypto.hmac(:sha256, @sec, Enum.join(["GET", url.host, url.path, ordered_query], "\n"))
    |> Base.encode64
    |> URI.encode_www_form

    signed_query = "#{url.query}&Signature=#{sig}"
    Map.put url, :query, signed_query
  end

  defp parse_response res do
    {doc, []} = res |> :binary.bin_to_list |> :xmerl_scan.string

    items = :xmerl_xpath.string('/ItemLookupResponse/Items/Item', doc)
    Enum.map items, fn item ->
      [title_node] = :xmerl_xpath.string('//ItemAttributes/Title', item)
      [title_text] = xmlElement title_node, :content
      title = xmlText title_text, :value

      [asin_node] = :xmerl_xpath.string('//ASIN', item)
      [asin_text] = xmlElement asin_node, :content
      asin = xmlText asin_text, :value

      %{asin: to_string(asin), title: to_string(title)}
    end
  end
end
