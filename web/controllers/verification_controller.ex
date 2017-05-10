defmodule Karma.VerificationController do
  use Karma.Web, :controller

  alias Karma.{User}

  def verify(conn, %{"hash" => hash}) do
    {:ok, email} = Base.hex_decode32(hash, padding: false)
    case Repo.get_by(User, email: email) do
      nil ->
        conn
        |> put_flash(:error, "Email not verified!")
        |> redirect(to: page_path(conn, :index))
      user ->
        changeset = User.email_verification_changeset(user, %{verified: true})
        case Repo.update(changeset) do
          {:ok, user} ->
            conn
            |> put_flash(:info, "Email #{user.email} verified!")
            |> redirect(to: page_path(conn, :index))
          {:error, changeset} ->
            conn
            |> put_flash(:error, "Error validating email!")
            |> redirect(to: page_path(conn, :index))
        end
    end
  end

end
