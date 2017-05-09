defmodule Karma.SessionController do
  use Karma.Web, :controller
  alias Karma.User

  def new(conn, _params) do
    case conn.assigns.current_user do
      nil ->
        changeset = User.changeset(%User{})
        render conn, "new.html", changeset: changeset
      _user ->
        conn
        |> put_flash(:info, "You are already logged in!")
        |> redirect(to: page_path(conn, :index))
    end

  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Karma.Auth.login_by_email_and_pass(conn, email, password, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome Back!")
        |> redirect(to: page_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid email/password combination")
        |> redirect(to: session_path(conn, :new))
    end
  end

  def delete(conn, _) do
    conn
    |> Karma.Auth.logout()
    |> redirect(to: session_path(conn, :new))
  end
end
