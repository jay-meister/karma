defmodule Karma.StartpackController do
  use Karma.Web, :controller

  alias Karma.Startpack

  def index(conn, _params) do
    startpacks = Repo.all(Startpack)
    render(conn, "index.html", startpacks: startpacks)
  end

  def new(conn, _params) do
    changeset = Startpack.changeset(%Startpack{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"startpack" => startpack_params}) do
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

  def show(conn, %{"id" => id}) do
    startpack = Repo.get!(Startpack, id)
    render(conn, "show.html", startpack: startpack)
  end

  def edit(conn, %{"id" => id}) do
    startpack = Repo.get!(Startpack, id)
    changeset = Startpack.changeset(startpack)
    render(conn, "edit.html", startpack: startpack, changeset: changeset)
  end

  def update(conn, %{"id" => id, "startpack" => startpack_params}) do
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

  def delete(conn, %{"id" => id}) do
    startpack = Repo.get!(Startpack, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(startpack)

    conn
    |> put_flash(:info, "Startpack deleted successfully.")
    |> redirect(to: startpack_path(conn, :index))
  end
end
