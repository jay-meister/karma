defmodule Engine.AdminDashboardControllerTest do
  use Engine.ConnCase

  setup do
    mother_setup()
  end

  test "admin dashboard restricted for non-admin user", %{conn: conn} do
    conn = get conn, admin_dashboard_path(conn, :index)
    assert Phoenix.Controller.get_flash(conn, :error) == "You do not have permission to view that page"
    assert redirected_to(conn, 302) == "/"
  end

  test "view admin dashboard" do
    user = insert_user(%{admin: true, email: "admin@email.com"})
    conn = login_user(build_conn(), user)
    conn = get conn, admin_dashboard_path(conn, :index)

    assert html_response(conn, 200) =~ "Admin dashboard"
  end

  test "view custom fields" do
    user = insert_user(%{admin: true, email: "admin@email.com"})
    conn = login_user(build_conn(), user)
    conn = get conn, admin_dashboard_path(conn, :custom_fields)

    assert html_response(conn, 200) =~ "Custom fields"
  end

  test "view users" do
    user = insert_user(%{admin: true, email: "admin@email.com"})
    conn = login_user(build_conn(), user)
    conn = get conn, admin_dashboard_path(conn, :users)

    assert html_response(conn, 200) =~ "Users"
  end
end
