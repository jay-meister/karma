defmodule Engine.S3 do

  alias Engine.{ViewHelpers}
  def upload_many(params, keys, identifier) do
    ops = [max_concurrency: System.schedulers_online() * 3, timeout: 20000]
    keys
    # remove keys that haven't been uploaded
    |> Enum.filter(fn({file_key, _url_key}) -> Map.has_key?(params, file_key) end)
    |> Enum.map(fn({file_key, url_key}) -> {url_key, Map.get(params, file_key), identifier} end)
    |> Task.async_stream(&upload/1, ops)
    |> Enum.to_list()
    |> Enum.filter(fn {_async_res, {res, _url_key, _url}} -> res != :error end)
    |> Enum.map(fn {_async_res, { _res, url_key, url}} -> {url_key, url} end)
    |> Enum.reduce(%{}, fn({url_key, url}, acc) -> Map.put(acc, url_key, url) end)
  end


  # image_params = %Plug.Upload{
  #  content_type: "image/png",
  #  filename: "Screen Shot 2017-06-05 at 16.36.15.png",
  #  path: "/var/folders/_p/46vn16c94z7cqz18w_3qxjb00000gn/T//plug-1496/multipart-909146-647759-1"
  # }
  def upload({url_key, image_params, identifier}) do
    # first check if user has uploaded an image
    unique_filename = get_unique_filename(image_params.filename, identifier)

    case File.read(image_params.path) do
      {:error, _} ->
        {:error, url_key, "file could not be read"}
      {:ok, image_binary} ->
        # returns image url string or error
        res = put_object(unique_filename, image_binary)
        Tuple.insert_at(res, 1, url_key)
        # {:ok, url_key, url}
    end
  end

  def get_unique_filename(filename, identifier) do
    date = DateTime.utc_now()
    day = Integer.to_string(date.day)
    month = ViewHelpers.find_month(date.month)
    year = Integer.to_string(date.year)
    hour = Integer.to_string(date.hour + 1)
    minutes = String.slice("0" <> Integer.to_string(date.minute), -2, 2)
    seconds = String.slice("0" <> Integer.to_string(date.second), -2, 2)
    timestamp = "#{day}_#{month}_#{year}_#{hour}:#{minutes}:#{seconds}"
    image_filename = String.replace(filename, " ", "_")
    "#{identifier}-#{image_filename}-#{timestamp}"
  end


  def put_object(unique, image_binary) do
    bucket = System.get_env("BUCKET_NAME")

    res = ExAws.S3.put_object(bucket, unique, image_binary)
    |> ExAws.request!

    case res do
      %{status_code: 200} ->
        {:ok, image_url(unique, bucket)}
      _ ->
        {:error, "error uploading to S3"}
    end
  end

  def get_many_objects(urls) do
    ops = [max_concurrency: System.schedulers_online() * 3, timeout: 20000]

    Task.async_stream(urls, &get_object/1, ops)
    |> Enum.to_list()
    |> Enum.filter(fn {:ok, {res, _file}} -> res != :error end)
    |> Enum.map(fn {_async_res, { _res, file}} -> file end)
  end

  def download(url, file_destination) do
    case get_object(url) do
      {:ok, body} ->
        case save_file_to_filepath(file_destination, body) do
          {:ok, filepath} -> {:ok, filepath}
          {:error, error} -> {:error, error}
        end
      {:error, error} -> {:error, error}
    end
  end

  def get_object(url) do
    bucket = System.get_env("BUCKET_NAME")
    [_host, path] = String.split(url, "https://#{bucket}.s3.amazonaws.com/#{bucket}")

    res = ExAws.S3.get_object(bucket, path)
    |> ExAws.request!

    case res do
      %{body: body, status_code: 200} ->
        {:ok, body}
      _error ->
        {:error, "error downloading from S3"}
    end
  end

  def save_file_to_filepath(destination, file) do
    res = File.write!("#{destination}", file)

    case res do
      :ok ->
        {:ok, "/#{destination}"}
      _error ->
        {:error, "error saving file"}
    end
  end

  def image_url(unique, bucket) do
    "https://#{bucket}.s3.amazonaws.com/#{bucket}/#{unique}"
  end
end
