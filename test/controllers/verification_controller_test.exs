defmodule Karma.VerificationControllerTest do
  use Karma.ConnCase, async: false

  alias Karma.{RedisCli}

  import Mock

  setup do
    RedisCli.flushdb()
  end

  test "/verification/:hash email exists", %{conn: conn} do
    user = insert_user(%{verified: false})
    RedisCli.set("RAND0M5TR1NG", user.email)
    conn = get conn, "/verification/RAND0M5TR1NG"
    assert redirected_to(conn, 302) == "/"
  end

  test "/verification/:hash email exists verified user", %{conn: conn} do
    user = insert_user()
    RedisCli.set("RAND0M5TR1NG", user.email)
    conn = get conn, "/verification/RAND0M5TR1NG"
    assert redirected_to(conn, 302) == "/"
  end

  test "/verification/:hash email exists in Redis, not Postgres", %{conn: conn} do
    RedisCli.set("RAND0M5TR1NG", "test@email.com")
    conn = get conn, "/verification/RAND0M5TR1NG"
    assert redirected_to(conn, 302) == "/users/new"
  end

  test "/verification/:hash email doesn't exist", %{conn: conn} do
    conn = get conn, "/verification/RAND0M5TR1NG"
    assert redirected_to(conn, 302) == "/users/new"
  end

  test "/verification/verify/:hash", %{conn: conn} do
    conn = get conn, verification_path(conn, :verify_again, "RAND0M5TR1NG")
    assert html_response(conn, 200) =~ "verification email"
  end

  test "/verification/resend/:hash", %{conn: conn} do
    with_mock Karma.Mailer, [deliver_later: fn(_) -> nil end] do
      user = insert_user()
      RedisCli.set("RAND0M5TR1NG", user.email)
      conn = get conn, verification_path(conn, :resend, "RAND0M5TR1NG")
      assert redirected_to(conn, 302) == "/sessions/new"
    end
  end

end
