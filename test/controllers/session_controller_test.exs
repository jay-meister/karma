defmodule Karma.SessionControllerTest do
  use Karma.ConnCase, async: false

  alias Karma.User

  describe "session routes that don't need authentication" do
    test "Get /sessions/new", %{conn: conn} do
      conn = get conn, session_path(conn, :new)
      assert html_response(conn, 200) =~ "Log in"
    end
  end

  describe "session routes that need authentication" do
    setup do
      insert_user(%{verified: true})

      conn = assign(build_conn(), :current_user, Repo.get(User, id().user))
      {:ok, conn: conn}
    end

    test "Get /sessions/new logged in", %{conn: conn} do
      user = insert_user(%{email: "test2@test.com"})
      conn =
        conn
        |> assign(:current_user, user)
      conn = get conn, session_path(conn, :new)
      assert redirected_to(conn, 302) == dashboard_path(conn, :index)
    end

    test "Login: Valid session /session/new", %{conn: conn} do
      conn = post conn, session_path(conn, :create,
      %{"session" => %{"email" => "test@test.com", "password" => "123456"}})
      assert redirected_to(conn, 302) == dashboard_path(conn, :index)
    end

    test "Login: Invalid session /sessions/new", %{conn: conn} do
      conn = post conn, session_path(conn, :create,
      %{"session" => %{"email" => "invalid@test.com", "password" => "invalid"}})
      assert html_response(conn, 302) =~ "/sessions/new"
    end

    test "Login: Invalid password", %{conn: conn} do
      conn = post conn, session_path(conn, :create,
      %{"session" => %{"email" => "test@test.com", "password" => "invld"}})
      assert html_response(conn, 302) =~ "/sessions/new"
    end

    test "Login: Not verified", %{conn: conn} do
      insert_user(%{email: "test2@test.com", verified: false})
      conn = post conn, session_path(conn, :create,
      %{"session" => %{"email" => "test2@test.com", "password" => "123456"}})
      assert html_response(conn, 302) =~ "/sessions/new"
    end

    test "Logout", %{conn: conn} do
      user = insert_user(%{email: "test2@test.com"})
      conn =
        conn
        |> assign(:current_user, user)
      conn = delete conn, session_path(conn, :delete, conn.assigns.current_user)
      assert redirected_to(conn, 302) == "/sessions/new"
    end
  end
end
