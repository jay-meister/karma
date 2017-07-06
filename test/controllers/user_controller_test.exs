defmodule Karma.UserControllerTest do
  use Karma.ConnCase

  import Mock

  alias Karma.{User, Email, RedisCli, Controllers.Helpers}

  @user_attrs %{email: "test@test.com"}
  @valid_attrs %{email: "test@test.com", first_name: "Joe", last_name: "Blogs", password: "Password123!", terms_accepted: true}
  @invalid_attrs %{email: ""}

  test "user paths require user authentication", %{conn: conn} do
    user = insert_user()

    Enum.each([
      get(conn, user_path(conn, :index)),
      get(conn, user_path(conn, :show, user)),
      get(conn, user_path(conn, :edit, user)),
      put(conn, user_path(conn, :update, user)),
      delete(conn, user_path(conn, :delete, user)),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end


  test "lists all entries on index", %{conn: conn} do
    user = insert_user()
    conn =
      conn
      |> login_user(user)
      |> get(user_path(conn, :index))
    assert html_response(conn, 200) =~ "Listing users"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "Create account"
  end

  test "email is pre-filled when sent from email", %{conn: conn} do
    hash = Helpers.gen_rand_string(30)
    RedisCli.query(["SET", hash, "test_prefill@gmail.com"])
    conn = get conn, user_path(conn, :new, te: hash)
    assert html_response(conn, 200) =~ "Create account"
    assert html_response(conn, 200) =~ "test_prefill@gmail.com"
  end

  test "creates resource and redirects when data is valid DEV", %{conn: conn} do
    with_mock Karma.Mailer, [deliver_later: fn(_) -> nil end] do
      Mix.env(:dev)
      conn = post conn, user_path(conn, :create), user: @valid_attrs
      assert redirected_to(conn) == session_path(conn, :new)
      assert Repo.get_by(User, @user_attrs)
    end
  end

  test "creates resource and redirects when data is valid not DEV", %{conn: conn} do
    with_mock Karma.Mailer, [deliver_later: fn(_) -> nil end] do
      Mix.env(:prod)
      conn = post conn, user_path(conn, :create), user: @valid_attrs
      assert redirected_to(conn) == session_path(conn, :new)
      assert Repo.get_by(User, @user_attrs)
      assert called Karma.Mailer.deliver_later(:_)
    end
  end

  test "creates resource and redirects with pre-filled email", %{conn: conn} do
    with_mock Karma.Mailer, [deliver_later: fn(_) -> nil end] do
      conn = post conn, user_path(conn, :create), user: @valid_attrs
      assert redirected_to(conn) == session_path(conn, :new)
      assert Repo.get_by(User, @user_attrs)
      assert called Karma.Mailer.deliver_later(:_)
    end
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Create account"
  end

  test "does not create resource and renders errors when data is invalid - pre-filled email", %{conn: conn} do
    hash = Helpers.gen_rand_string(30)
    RedisCli.query(["SET", hash, "test_prefill@gmail.com"])
    conn = post conn, user_path(conn, :create, te: hash), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Create account"
    assert html_response(conn, 200) =~ "test_prefill@gmail.com"
  end

  test "shows chosen resource", %{conn: conn} do
    user = insert_user()
    conn =
      conn
      |> login_user(user)
      |> get(user_path(conn, :show, user))
    assert html_response(conn, 200) =~ ""
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    user = insert_user()
    conn =
      conn
      |> login_user(user)
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    user = insert_user()
    conn =
      conn
      |> login_user(user)
      |> get(user_path(conn, :edit, user))
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    user = insert_user()
    conn =
      conn
      |> login_user(user)
      |> put(user_path(conn, :update, user), user: @valid_attrs)
    assert redirected_to(conn) == user_path(conn, :show, user)
    assert Repo.get_by(User, @user_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = insert_user()
    conn =
      conn
      |> login_user(user)
      |> put(user_path(conn, :update, user), user: @invalid_attrs)
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "deletes chosen resource", %{conn: conn} do
    user = insert_user()
    conn =
      conn
      |> login_user(user)
      |> delete(user_path(conn, :delete, user))
    assert redirected_to(conn) == user_path(conn, :index)
    refute Repo.get(User, user.id)
  end

  test "does not create new user if terms_accepted are not accepted", %{conn: conn} do
    invalid_user = %{ @valid_attrs | terms_accepted: false }

    conn = post conn, user_path(conn, :create), user: invalid_user
    # assert the error message is displayed
    assert html_response(conn, 200) =~ "You must agree to the terms and conditions"
  end

  test "structure of verification email is ok" do
    email = Email.send_html_email("test@email.com", "Welcome", "Hello!", "verify", [first_name: "Test"])
    assert email.to == "test@email.com"
    assert email.subject == "Welcome"
    assert email.text_body =~ "Hello!"
  end

end
