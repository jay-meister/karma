defmodule Karma.SigneeController do
  use Karma.Web, :controller

  alias Karma.{Signee, Project}

  def create(conn, %{"project_id" => project_id, "signee" => signee_params}) do
    project = Repo.get_by(Project, id: project_id)

    changeset =
      project
      |> build_assoc(:signees)
      |> Signee.changeset(signee_params)
    case Repo.insert(changeset) do
      {:ok, signee} ->
        conn
        |> put_flash(:info, "#{signee.name} added as a signee to #{project.name}")
        |> redirect(to: project_path(conn, :show, project_id))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to add signee! Make sure you have filled out all fields and email is in the correct format")
        |> redirect(to: project_path(conn, :show, project_id))
    end
  end

  def delete(conn, %{"id" => id, "project_id" => project_id}) do
    project = Repo.get_by(Project, id: project_id)
    signee = Repo.get!(Signee, id)
    Repo.delete!(signee)
    conn
    |> put_flash(:info, "Signee deleted successfully.")
    |> redirect(to: project_path(conn, :show, project))
  end
end
