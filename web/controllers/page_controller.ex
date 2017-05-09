defmodule Karma.PageController do
  use Karma.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
