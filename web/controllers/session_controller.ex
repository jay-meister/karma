defmodule Karma.SessionController do
  use Karma.Web, :controller
  alias Karma.{User, RedisCli, LayoutView}

  def new(conn, _params) do
    case conn.assigns.current_user do
      nil ->
        changeset = User.changeset(%User{})
        render conn, "new.html", layout: {LayoutView, "pre_login.html"}, changeset: changeset
      _user ->
        conn
        |> put_flash(:info, "You are already logged in!")
        |> redirect(to: dashboard_path(conn, :index))
    end

  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Karma.Auth.login_by_email_and_pass(conn, email, password, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome Back!")
        |> redirect(to: dashboard_path(conn, :index))
      {:error, :unauthorized, conn} ->
        conn
        |> put_flash(:error, "Invalid email/password combination")
        |> redirect(to: session_path(conn, :new))
      {:error, :not_verified, conn} ->
        rand_string = gen_rand_string(30)
        RedisCli.query(["SET", rand_string, email])
        RedisCli.query(["SET", email, rand_string])
        conn
        |> put_flash(:error, "Email address not verified!")
        |> redirect(to: verification_path(conn, :verify_again, rand_string))
    end
  end

  def delete(conn, _) do
    conn
    |> Karma.Auth.logout()
    |> redirect(to: session_path(conn, :new))
  end
end
