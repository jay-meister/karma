defmodule Karma.S3Test do
  use Karma.ConnCase

  import Mock
  alias Karma.S3

  @bucket System.get_env("BUCKET_NAME")
  @image_params %{filename: "unique.png", path: "./maybe/mocked"}

  test "unique filename" do
    filename = "foxy.png"
    unique = S3.get_unique_filename(filename)

    assert [uuid, file] = String.split(unique, "-")
    assert file == filename
    assert String.length(uuid) > 8
  end

  test "put_object failure function" do
    with_mock ExAws, [request!: fn(_) -> %{status_code: 500} end] do
      res = S3.put_object("unique.png", "binary")
      assert res == {:error, "error uploading to S3"}
    end
  end

  test "put_object success function" do
    with_mock ExAws, [request!: fn(_) -> %{status_code: 200} end] do
      res = S3.put_object("unique.png", "binary")
      assert res == {:ok, "https://#{@bucket}.s3.amazonaws.com/#{@bucket}/unique.png"}
    end
  end


  test "S3.upload_many with no file uploaded" do
    keys = [{"passport_image", "passport_url"}]
    res = S3.upload_many(%{}, keys)
    assert res == %{}
  end

  test "S3.upload failure" do
    with_mock ExAws, [request!: fn(_) -> %{status_code: 200} end] do
      res = S3.upload({"passport_url", @image_params})
      assert {:error, "passport_url", "file could not be read"} == res
    end
  end

  test "S3.upload success" do
    url_key = "passport_url"
    with_mock ExAws, [request!: fn(_) -> %{status_code: 200} end] do
      with_mock File, [read: fn(_) -> {:ok, "image_binary"} end] do
        res = S3.upload({url_key, @image_params})
        assert {:ok, ^url_key, url} = res
        beginning = "https://#{@bucket}.s3.amazonaws.com/#{@bucket}/"

        assert String.starts_with?(url, beginning)
        assert String.ends_with?(url, @image_params.filename)
      end
    end
  end
end
