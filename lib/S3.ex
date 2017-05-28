defmodule Karma.S3 do
  def upload_many(params, keys) do
    keys
    # remove keys that haven't been uploaded
    |> Enum.filter(fn({file_key, _url_key}) -> Map.has_key?(params, file_key) end)
    |> Enum.reduce([], fn({file_key, url_key}, acc) ->
        file = Map.get(params, file_key)
        task = Task.async(Karma.S3, :upload, [url_key, file])
        [task | acc]
      end)
    |> IO.inspect
    |> Enum.map(&Task.await/1)
    |> IO.inspect
    |> Enum.filter(fn {res, _url_key, _url} -> res != :error end)
    |> IO.inspect
    |> Enum.map(fn { _res, url_key, url} -> {url_key, url} end)
    |> IO.inspect
    |> Enum.reduce(%{}, fn({url_key, url}, acc) -> Map.put(acc, url_key, url) end)
    |> IO.inspect
  end

  def upload(url_key, image_params) do
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
    image_filename = filename
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

  def image_url(unique, bucket) do
    "https://#{bucket}.s3.amazonaws.com/#{bucket}/#{unique}"
  end
end
