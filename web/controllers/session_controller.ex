defmodule Karma.SessionController do
  use Karma.Web, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end

  # placeholder
  def create(conn, _params) do
    render(conn, "new.html")
  end
end
