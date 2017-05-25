defmodule Karma.StartpackController do
  use Karma.Web, :controller

  alias Karma.{Startpack, Offer, Controllers.Helpers}

  def index(conn, _params, user) do
    offer_id =
      case Map.has_key?(conn.query_params, "offer_id") do
        true ->  String.to_integer(conn.query_params["offer_id"])
        false -> ""
      end
    IO.inspect offer_id
    offer =
      case Repo.get_by(Offer, id: offer_id) do
        nil -> ""
        offer -> offer
      end
    startpack = Repo.one(Helpers.user_startpack(user))
    IO.inspect offer
    changeset = Startpack.mother_changeset(%Startpack{}, Map.from_struct(startpack), offer)
    changeset = %{changeset | action: :insert} 
    startpacks = Repo.all(user_startpack(user))
    startpack_map = Map.from_struct(Repo.one(Helpers.user_startpack(user)))
    # changeset = Startpack.changeset(%Startpack{}, startpack_map)
    IO.inspect changeset
    render(conn, "index.html", startpacks: startpacks, startpack: startpack, changeset: changeset)
  end

  def create(conn, %{"startpack" => startpack_params}, user) do
    changeset = Startpack.changeset(%Startpack{}, startpack_params)

    case Repo.insert(changeset) do
      {:ok, _startpack} ->
        conn
        |> put_flash(:info, "Startpack created successfully.")
        |> redirect(to: startpack_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    startpack = Repo.get!(Helpers.user_startpack(user), id)
    render(conn, "show.html", startpack: startpack)
  end

  def edit(conn, %{"id" => id}, user) do
    startpack = Repo.get!(Helpers.user_startpack(user), id)
    changeset = Startpack.changeset(startpack)
    render(conn, "edit.html", startpack: startpack, changeset: changeset)
  end

  def update(conn, %{"id" => id, "startpack" => startpack_params}, user) do
    startpack = Repo.get!(Startpack, id)
    changeset = Startpack.changeset(startpack, startpack_params)

    case Repo.update(changeset) do
      {:ok, startpack} ->
        conn
        |> put_flash(:info, "Startpack updated successfully.")
        |> redirect(to: startpack_path(conn, :show, startpack))
      {:error, changeset} ->
        render(conn, "edit.html", startpack: startpack, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    startpack = Repo.get!(Startpack, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(startpack)

    conn
    |> put_flash(:info, "Startpack deleted successfully.")
    |> redirect(to: startpack_path(conn, :index))
  end

  # def user_startpack(user) do
  #   assoc(user, :startpacks)
  # end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end
end
