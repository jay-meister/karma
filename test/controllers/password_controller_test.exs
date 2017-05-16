defmodule Karma.PasswordControllerTest do
  use Karma.ConnCase

  import Mock

  alias Karma.{Email, RedisCli}

  setup do
    RedisCli.flushdb()
  end


  @valid_attrs %{email: "test@test.com"}
  @valid_password %{password: "123456", password_confirmation: "123456"}
  @invalid_attrs %{email: "teeheehee@.com"}


  test "structure of password reset email is ok" do
    email = Email.send_html_email("test@email.com", "Password reset", "www.example.com/reset_password", "password_reset")
    assert email.to == "test@email.com"
    assert email.subject == "Password reset"
    assert email.text_body =~ "www.example.com/reset_password"
  end

  test "/password/new renders form", %{conn: conn} do
    conn = get(conn, password_path(conn, :new))
    assert html_response(conn, 200) =~ "Forgot your password?"
  end

  test "password :create with recognised email address", %{conn: conn} do
    with_mock Karma.Mailer, [deliver_later: fn(_) -> nil end] do
      user = insert_user()
      conn = post(conn, password_path(conn, :create), user: @valid_attrs)
      # test response
      assert redirected_to(conn) == session_path(conn, :new)
      assert Phoenix.Controller.get_flash(conn, :info) =~ "A password reset email has been sent to #{user.email}"
      # test Redis has key, which represents our email
      {:ok, [key]} = RedisCli.query(["keys", "*"])
      assert RedisCli.get(key) == {:ok, "test@test.com"}
      # test key is set to expire in 5 mins
      {:ok, ttl} = RedisCli.query(["ttl", key])
      assert ttl == 300
    end
  end

  test "password :create with fake email address", %{conn: conn} do
    conn = post(conn, password_path(conn, :create), user: @invalid_attrs)
    assert redirected_to(conn) == password_path(conn, :new)
    assert Phoenix.Controller.get_flash(conn, :error) =~ "Something went wrong, please try again later"
  end

  test "password :edit with good email", %{conn: conn} do
    RedisCli.set("RAND0M5TR1NG", "test@test.com")
    conn = get conn, password_path(conn, :edit, 1, hash: "RAND0M5TR1NG")
    assert html_response(conn, 200) =~ "Reset your password"
  end

  test "password :edit with bad email or expired link", %{conn: conn} do
    conn = get conn, password_path(conn, :edit, 1, hash: "RAND0M5TR1NG")
    assert Phoenix.Controller.get_flash(conn, :error) =~ "That link has expired"
    assert redirected_to(conn) =~ password_path(conn, :new)
  end

  test "password :update with good email", %{conn: conn} do
    insert_user()
    RedisCli.set("RAND0M5TR1NG", "test@test.com")
    conn = put conn, password_path(conn, :update, 1, hash: "RAND0M5TR1NG"), %{user: @valid_password}
    assert Phoenix.Controller.get_flash(conn, :info) =~ "Password updated successfully"
    assert redirected_to(conn) =~ dashboard_path(conn, :index)

    # Log in user with new password
    valid_login = %{email: "test@test.com", password: "123456"}
    conn = post conn, session_path(conn, :create), %{session: valid_login}
    assert Phoenix.Controller.get_flash(conn, :info) =~ "Welcome Back"
    assert redirected_to(conn) =~ dashboard_path(conn, :index)
  end

  test "password :update with good email, but bad password/confirm password", %{conn: conn} do
    insert_user()
    RedisCli.set("RAND0M5TR1NG", "test@test.com")
    invalid_passwords = %{@valid_password | password_confirmation: "11111111"}
    conn = put conn, password_path(conn, :update, 1, hash: "RAND0M5TR1NG"), %{user: invalid_passwords}
    assert html_response(conn, 200) =~ "Passwords do not match"
  end

  test "password :update with expired/unrecognised email", %{conn: conn} do
    conn = put conn, password_path(conn, :update, 1, hash: "RAND0M5TR1NG"), %{user: @valid_password}
    assert Phoenix.Controller.get_flash(conn, :error) =~ "That link has expired"
    assert redirected_to(conn) =~ password_path(conn, :new)
  end

end
