defmodule Karma.S3 do
  def upload_many(params, keys) do
    ops = [max_concurrency: System.schedulers_online() * 3, timeout: 20000]
    keys
    # remove keys that haven't been uploaded
    |> Enum.filter(fn({file_key, _url_key}) -> Map.has_key?(params, file_key) end)
    |> Enum.map(fn({file_key, url_key}) -> {url_key, Map.get(params, file_key)} end)
    |> Task.async_stream(&upload/1, ops)
    |> Enum.to_list()
    |> Enum.filter(fn {_async_res, {res, _url_key, _url}} -> res != :error end)
    |> Enum.map(fn {_async_res, { _res, url_key, url}} -> {url_key, url} end)
    |> Enum.reduce(%{}, fn({url_key, url}, acc) -> Map.put(acc, url_key, url) end)
  end

  def upload({url_key, image_params}) do
    # first check if user has uploaded an image
    unique_filename = get_unique_filename(image_params.filename)

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


  def get_unique_filename(filename) do
    file_uuid = UUID.uuid4(:hex)
    image_filename = String.replace(filename, " ", "_")
    "#{file_uuid}-#{image_filename}"
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

  def get_object(url) do
    bucket = System.get_env("BUCKET_NAME")
    [_host, path] = String.split(url, "https://#{bucket}.s3.amazonaws.com/#{bucket}")

    res = ExAws.S3.get_object(bucket, path)
    |> ExAws.request!

    case res do
      %{body: body, headers: _headers, status_code: 200} ->
        body
      _error ->
        {:error, "error downloading from S3"}
    end
  end

  def save_file_to_filepath(destination, file) do
    res = File.write!("#{destination}", file)

    case res do
      :ok ->
        "/#{destination}"
      _error ->
        {:error, "error saving file"}
    end
  end

  def image_url(unique, bucket) do
    "https://#{bucket}.s3.amazonaws.com/#{bucket}/#{unique}"
  end
end
