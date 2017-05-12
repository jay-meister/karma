defmodule Karma.Controllers.Helpers do

  alias Karma.RedisCli

  def get_email_from_hash(hash) do
    case RedisCli.get(hash) do
      {:ok, nil} -> {:error, "User not in Redis"}
      {:ok, email} -> {:ok, email}
    end
  end

end
