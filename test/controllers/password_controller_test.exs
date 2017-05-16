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
    # NOTE should mock the email function
    user = insert_user()
    conn = post(conn, password_path(conn, :create), user: @valid_attrs)
    assert redirected_to(conn) == session_path(conn, :new)
    assert Phoenix.Controller.get_flash(conn, :info) =~ "A password reset email has been sent to #{user.email}"
  end

  test "password :create with fake email address", %{conn: conn} do
    conn = post(conn, password_path(conn, :create), user: @invalid_attrs)
    assert redirected_to(conn) == password_path(conn, :new)
    assert Phoenix.Controller.get_flash(conn, :error) =~ "Something went wrong, please try again later"
  end

  # test "creates resource and redirects when data is valid DEV", %{conn: conn} do
  #   with_mock Karma.Mailer, [deliver_later: fn(_) -> nil end] do
  #     Mix.env(:dev)
  #     conn = post conn, user_path(conn, :create), user: @valid_attrs
  #     assert redirected_to(conn) == session_path(conn, :new)
  #     assert Repo.get_by(User, @user_attrs)
  #   end
  # end
  #
  # test "creates resource and redirects when data is valid not DEV", %{conn: conn} do
  #   with_mock Karma.Mailer, [deliver_later: fn(_) -> nil end] do
  #     Mix.env(:prod)
  #     conn = post conn, user_path(conn, :create), user: @valid_attrs
  #     assert redirected_to(conn) == session_path(conn, :new)
  #     assert Repo.get_by(User, @user_attrs)
  #     assert called Karma.Mailer.deliver_later(:_)
  #   end
  # end
  #
  # test "lists all entries on index", %{conn: conn} do
  #   user = insert_user()
  #   conn =
  #     conn
  #     |> login_user(user)
  #     |> get(user_path(conn, :index))
  #   assert html_response(conn, 200) =~ "Listing users"
  # end
  #
  # test "renders form for new resources", %{conn: conn} do
  #   conn = get conn, user_path(conn, :new)
  #   assert html_response(conn, 200) =~ "New user"
  # end
  #
  # test "creates resource and redirects when data is valid DEV", %{conn: conn} do
  #   with_mock Karma.Mailer, [deliver_later: fn(_) -> nil end] do
  #     Mix.env(:dev)
  #     conn = post conn, user_path(conn, :create), user: @valid_attrs
  #     assert redirected_to(conn) == session_path(conn, :new)
  #     assert Repo.get_by(User, @user_attrs)
  #   end
  # end
  #
  # test "creates resource and redirects when data is valid not DEV", %{conn: conn} do
  #   with_mock Karma.Mailer, [deliver_later: fn(_) -> nil end] do
  #     Mix.env(:prod)
  #     conn = post conn, user_path(conn, :create), user: @valid_attrs
  #     assert redirected_to(conn) == session_path(conn, :new)
  #     assert Repo.get_by(User, @user_attrs)
  #     assert called Karma.Mailer.deliver_later(:_)
  #   end
  # end
  #
  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, user_path(conn, :create), user: @invalid_attrs
  #   assert html_response(conn, 200) =~ "New user"
  # end
  #
  # test "shows chosen resource", %{conn: conn} do
  #   user = insert_user()
  #   conn =
  #     conn
  #     |> login_user(user)
  #     |> get(user_path(conn, :show, user))
  #   assert html_response(conn, 200) =~ ""
  # end
  #
  # test "renders page not found when id is nonexistent", %{conn: conn} do
  #   user = insert_user()
  #   conn =
  #     conn
  #     |> login_user(user)
  #   assert_error_sent 404, fn ->
  #     get conn, user_path(conn, :show, -1)
  #   end
  # end
  #
  # test "renders form for editing chosen resource", %{conn: conn} do
  #   user = insert_user()
  #   conn =
  #     conn
  #     |> login_user(user)
  #     |> get(user_path(conn, :edit, user))
  #   assert html_response(conn, 200) =~ "Edit user"
  # end
  #
  # test "updates chosen resource and redirects when data is valid", %{conn: conn} do
  #   user = insert_user()
  #   conn =
  #     conn
  #     |> login_user(user)
  #     |> put(user_path(conn, :update, user), user: @valid_attrs)
  #   assert redirected_to(conn) == user_path(conn, :show, user)
  #   assert Repo.get_by(User, @user_attrs)
  # end
  #
  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   user = insert_user()
  #   conn =
  #     conn
  #     |> login_user(user)
  #     |> put(user_path(conn, :update, user), user: @invalid_attrs)
  #   assert html_response(conn, 200) =~ "Edit user"
  # end
  #
  # test "deletes chosen resource", %{conn: conn} do
  #   user = insert_user()
  #   conn =
  #     conn
  #     |> login_user(user)
  #     |> delete(user_path(conn, :delete, user))
  #   assert redirected_to(conn) == user_path(conn, :index)
  #   refute Repo.get(User, user.id)
  # end
  #
  # test "does not create new user if terms_accepted are not accepted", %{conn: conn} do
  #   invalid_user = %{ @valid_attrs | terms_accepted: false }
  #
  #   conn = post conn, user_path(conn, :create), user: invalid_user
  #   # assert the error message is displayed
  #   assert html_response(conn, 200) =~ "You must agree to the terms and conditions"
  # end


end
