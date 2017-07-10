defmodule Karma.InfoControllerTest do
  use Karma.ConnCase

  setup do
    user = insert_user() # This represents the user that created the project (PM)
    conn = login_user(build_conn(), user)
    {:ok, conn: conn, user: user}
  end

  test "/terms", %{conn: conn} do
    conn = get conn, info_path(conn, :terms)
    assert html_response(conn, 200) =~ "Terms of use"
  end

  test "/privacy", %{conn: conn} do
    conn = get conn, info_path(conn, :privacy)
    assert html_response(conn, 200) =~ "Privacy"
  end
end
