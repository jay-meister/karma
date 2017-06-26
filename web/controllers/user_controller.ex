defmodule Karma.UserController do
  use Karma.Web, :controller

  plug :authenticate when action in [:index, :show, :edit, :update, :delete]

  alias Karma.{User, LayoutView}

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", layout: {LayoutView, "pre_login.html"}, changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    user_params = Map.merge(%{"startpacks" => %{}}, user_params)
    changeset = User.registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        Karma.Email.send_verification_email(user)
        |> Karma.Mailer.deliver_later()

        # update offers user_id to all offers for this user
        from(o in Karma.Offer, where: o.target_email == ^user.email)
        |> Repo.update_all(set: [user_id: user.id])

        conn
        |> put_flash(:info, "A verification email has been sent to #{user.email}.
        Click the link in the email to gain full access to Karma.")
        |> redirect(to: session_path(conn, :new))
      {:error, changeset} ->
        render(conn, "new.html", layout: {LayoutView, "pre_login.html"}, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end
end
