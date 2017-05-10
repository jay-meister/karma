defmodule Karma.DashboardController do
  use Karma.Web, :controller

  plug :authenticate when action in [:index]

  def index(conn, _params) do
    render conn, "index.html"
  end
end
