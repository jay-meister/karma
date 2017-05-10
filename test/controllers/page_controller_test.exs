defmodule Karma.PageControllerTest do
  use Karma.ConnCase

  test "GET /", %{conn: conn} do
    user = insert_user()
    conn =
      conn
      |> login_user(user)
      |> get("/")
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
  end
end
