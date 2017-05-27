defmodule Karma.S3 do
  def upload_many(params, keys) do
    keys
    # remove keys that haven't been uploaded
    |> Enum.filter(fn({file_key, _url_key}) -> Map.has_key?(params, file_key) end)
    |> Enum.reduce(%{}, fn({file_key, url_key}, acc) ->
        file = Map.get(params, file_key)
        case upload(file) do
          {:error, _msg} -> acc
          {:ok, image_url} -> Map.put(acc, url_key, image_url)
        end
      end)
  end

  def upload(image_params) do
    # first check if user has uploaded an image
    unique_filename = get_unique_filename(image_params.filename)

    case File.read(image_params.path) do
      {:error, _} ->
        {:error, "file could not be read"}
      {:ok, image_binary} ->
        # returns image url string or error
        put_object(unique_filename, image_binary)
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
