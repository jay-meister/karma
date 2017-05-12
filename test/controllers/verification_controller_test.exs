defmodule Karma.VerificationControllerTest do
  use Karma.ConnCase, async: false

  alias Karma.RedisCli

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

end
