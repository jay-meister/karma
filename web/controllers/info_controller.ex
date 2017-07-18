defmodule Engine.InfoController do
  use Engine.Web, :controller

  def terms(conn, _params) do
    render conn, "terms.html"
  end

  def privacy(conn, _params) do
    render conn, "privacy.html"
  end
end
