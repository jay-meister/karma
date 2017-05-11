defmodule Karma.VerificationControllerTest do
  use Karma.ConnCase, async: false

  test "/verification/:hash email exists", %{conn: conn} do
    user = insert_user()
    email = user.email
    hash = Base.hex_encode32(email, padding: false)
    conn = get conn, "/verification/#{hash}"
    assert redirected_to(conn, 302) == "/"
  end

  test "/verification/:hash email doesn't exist", %{conn: conn} do
    hash = Base.hex_encode32("notanemail", padding: false)
    conn = get conn, "/verification/#{hash}"
    assert redirected_to(conn, 302) == "/"
  end

end
