defmodule Karma.RedisClientSupervisor do
  use Supervisor

  alias Karma.RedisCli

  def start_link do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      worker(RedisCli, [System.get_env("REDIS_URL"), :redix], [])
    ]
    supervise(children, strategy: :one_for_one)
  end
end
