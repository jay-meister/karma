defmodule Karma.VerificationController do
  use Karma.Web, :controller

  def verify(conn, params) do
    IO.inspect params
    conn
    |> put_flash(:info, "Email verified!")
    |> redirect(to: page_path(conn, :index))
  end

end
