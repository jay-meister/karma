defmodule Engine.DashboardControllerTest do
  use Engine.ConnCase

  test "dashboard requires user authentication", %{conn: conn} do
    conn = get(conn, dashboard_path(conn, :index))
    assert html_response(conn, 302)
    assert conn.halted
  end

  test "GET /", %{conn: conn} do
    user = insert_user()
    conn =
      conn
      |> login_user(user)
      |> get("/")
    assert html_response(conn, 200) =~ "Projects"
  end
end
