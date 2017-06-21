defmodule Karma.SigneeController do
  use Karma.Web, :controller

  alias Karma.{Signee, Project, DocumentSignee, Document}

  def create(conn, %{"project_id" => project_id, "signee" => signee_params}, user) do
    project = Repo.get(user_projects(user), project_id)

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

  def delete(conn, %{"id" => id, "project_id" => project_id}, user) do
    project = Repo.get(user_projects(user), project_id)
    signee = Repo.get!(Signee, id)
    Repo.delete!(signee)
    conn
    |> put_flash(:info, "Signee deleted successfully.")
    |> redirect(to: project_path(conn, :show, project))
  end

  def add(conn, %{"project_id" => project_id, "document_id" => document_id}, user) do
    case Repo.get(user_projects(user), project_id) do
      nil ->
        conn
        |> put_flash(:error, "Project doesn't exist")
        |> render(Karma.ErrorView, "404.html")
        |> halt()
      project ->
        case Repo.get(project_documents(project), document_id) do
          nil ->
            conn
            |> put_flash(:error, "Document doesn't exist")
            |> redirect(to: project_path(conn, :show, project))
            |> halt()
          document ->
            signees = Repo.all(project_signees(project))
            signee_names = Enum.map(signees, fn signee -> {signee.name, signee.id} end)
            document_signees = Repo.all(document_signees(document))
            changeset = DocumentSignee.changeset(%DocumentSignee{})

            render conn,
            "new.html",
            signees: signee_names,
            project: project,
            changeset: changeset,
            document: document,
            document_signees: document_signees
        end
    end
  end

  def add_signee(conn, %{"project_id" => project_id, "document_id" => document_id, "document_signee" => %{"signee_id" => signee_id, "order" => order}}, user) do
    project = Repo.get(user_projects(user), project_id)
    document = Repo.get(project_documents(project), document_id)
    changes = %{document_id: document_id, signee_id: signee_id, order: order}
    changeset = DocumentSignee.changeset(%DocumentSignee{}, changes)
    case Repo.insert(changeset) do
      {:ok, document_signee} ->
        loaded_signee = document_signee |> Repo.preload(:signee)
        conn
        |> put_flash(:info, "Signee #{loaded_signee.signee.name} added to document approval chain!")
        |> redirect(to: project_document_signee_path(conn, :add, project, document))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "You must select a signee")
        |> redirect(to: project_document_signee_path(conn, :add, project, document))
    end
  end

  def clear_signees(conn, %{"project_id" => project_id, "document_id" => document_id}, _user) do
    project = Repo.get(Project, project_id)
    document = Repo.get(Document, document_id)
    document_signees = from d in DocumentSignee, where: d.document_id == ^document_id
    case Repo.delete_all(document_signees) do
      {num, _result} ->
        conn
        |> put_flash(:info, "#{num} Signees cleared successfully!")
        |> redirect(to: project_document_signee_path(conn, :add, project, document))
    end
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end
end
