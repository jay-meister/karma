defmodule Karma.PasswordControllerTest do
  use Karma.ConnCase

  import Mock

  alias Karma.{Email, RedisCli}

  setup do
    RedisCli.flushdb()
  end


  @valid_attrs %{email: "test@test.com"}
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



end
