defmodule Engine.VerificationController do
  use Engine.Web, :controller

  alias Engine.{User, Auth}

  def verify(conn, %{"hash" => hash}) do
    case get_email_from_hash(hash) do
      {:error, _error} ->
        conn
        |> put_flash(:error, "User doesn't exist!")
        |> redirect(to: user_path(conn, :new))
      {:ok, email} ->
        case Repo.get_by(User, email: email) do
          nil ->
            conn
            |> put_flash(:error, "User doesn't exist!")
            |> redirect(to: user_path(conn, :new))
          user ->
            case user.verified do
              true ->
                conn
                |> put_flash(:error, "Email already verified!")
                |> redirect(to: dashboard_path(conn, :index))
              false ->
                changeset = User.email_verification_changeset(user, %{verified: true})
                {:ok, user} = Repo.update(changeset)
                conn
                |> Auth.login(user)
                |> put_flash(:info, "Email #{user.email} verified!")
                |> redirect(to: dashboard_path(conn, :index))
            end
        end
    end
  end

  def verify_again(conn, %{"hash" => hash}) do
    render conn, "verify_again.html", hash: hash
  end

  def resend(conn, %{"hash" => hash}) do
    {:ok, email} = get_email_from_hash(hash)
    user = Repo.get_by(User, email: email)

    Engine.Email.send_verification_email(user)
    |> Engine.Mailer.deliver_later()
    conn
    |> put_flash(:info, "A new verification email has been sent to #{user.email}")
    |> redirect(to: session_path(conn, :new))
  end

end
