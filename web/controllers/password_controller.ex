defmodule Karma.PasswordController do
  use Karma.Web, :controller

  alias Karma.User

  def new(conn, _params) do
    # render form allowing user to enter email address
    changeset = User.email_changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => password_params}) do
    # if they are there, send email, store in redis, expire
    email = password_params["email"]
    user = case user = Repo.get_by(User, email: email) do
      nil ->
        # if user not found, just let them know something not working
        conn
        |> put_flash(:error, "Something went wrong, please try again later")
        |> redirect(to: password_path(conn, :new))
      %User{} ->
        # if email is found, send reset email
        # need to hash the user id!
        url = password_url(conn, :edit, user.id)
        Karma.Email.send_reset_password_email(user, url)
        |> Karma.Mailer.deliver_later()
        conn
        |> put_flash(:info, "A password reset email has been sent to #{user.email}, it will expire in 5 minutes")
        |> redirect(to: session_path(conn, :new))

        # store random key in redis table
        # set to expire
    end
    IO.inspect user
    # render conn, "new.html"
  end

  def edit(conn, params) do
    # render form for create new password and confirm new password
    render conn, "new.html"
  end
  def update(conn, _params) do
    # if password valid, update user
    render conn, "new.html"
  end
end
