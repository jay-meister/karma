defmodule Karma.DocumentController do
  use Karma.Web, :controller

  alias Karma.{Document, Project, S3}

  def index(conn, %{"project_id" => project_id}) do
    documents = Repo.all(Document)
    project = Repo.get_by(Project, id: project_id)
    render(conn, "index.html", documents: documents, project: project)
  end

  def new(conn, %{"project_id" => project_id}) do
    changeset = Document.changeset(%Document{})
    project = Repo.get_by(Project, id: project_id)
    render(conn, "new.html", changeset: changeset, project: project)
  end

  def create(conn, %{"document" => %{"file" => file_params} = document_params, "project_id" => project_id}) do
    project = Repo.get_by(Project, id: project_id)

    case S3.upload({:url, file_params}) do
      {:ok, :url, url} ->
        document_params =
          Map.delete(document_params, "file")
          |> Map.put_new("url", url)
      {:error, :url, error} ->
        conn
        |> put_flash(:error, "Error uploading document!")
        |> redirect(to: project_path(conn, :show, project))
    end

    changeset =
      project
      |> build_assoc(:documents)
      |> Document.changeset(document_params)

    case Repo.insert(changeset) do
      {:ok, _document} ->
        conn
        |> put_flash(:info, "Document uploaded successfully.")
        |> redirect(to: project_path(conn, :show, project))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Error uploading document!")
        |> redirect(to: project_path(conn, :show, project))
    end
  end

  def show(conn, %{"id" => id, "project_id" => project_id}) do
    document = Repo.get!(Document, id)
    project = Repo.get_by(Project, id: project_id)
    render(conn, "show.html", document: document, project: project)
  end

  def edit(conn, %{"id" => id, "project_id" => project_id}) do
    document = Repo.get!(Document, id)
    project = Repo.get_by(Project, id: project_id)
    changeset = Document.changeset(document)
    render(conn, "edit.html", document: document, changeset: changeset, project: project)
  end

  def update(conn, %{"id" => id, "document" => document_params, "project_id" => project_id}) do
    document = Repo.get!(Document, id)
    project = Repo.get_by(Project, id: project_id)
    changeset = Document.changeset(document, document_params)

    case Repo.update(changeset) do
      {:ok, document} ->
        conn
        |> put_flash(:info, "Document updated successfully.")
        |> redirect(to: project_document_path(conn, :show, project, document))
      {:error, changeset} ->
        render(conn, "edit.html", document: document, changeset: changeset, project: project)
    end
  end

  def delete(conn, %{"id" => id, "project_id" => project_id}) do
    project = Repo.get_by(Project, id: project_id)
    document = Repo.get!(Document, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(document)

    conn
    |> put_flash(:info, "Document deleted successfully.")
    |> redirect(to: project_document_path(conn, :index, project))
  end
end
