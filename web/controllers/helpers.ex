defmodule Karma.Controllers.Helpers do

  alias Karma.RedisCli

  def get_email_from_hash(hash) do
    case RedisCli.get(hash) do
      {:ok, nil} -> {:error, "User not in Redis"}
      {:ok, email} -> {:ok, email}
    end
  end

  def get_base_url() do
    dev_env? = Mix.env == :dev
    case dev_env? do
      true -> System.get_env("DEV_URL")
      false -> System.get_env("PROD_URL")
    end
  end

  def gen_rand_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end

end
