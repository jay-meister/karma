defmodule Karma.DocumentController do
  use Karma.Web, :controller

  alias Karma.{Document, Project, S3}

  # stop upload functionality if documents are submitted with existing type
  plug :file_type_exists? when action in [:create]


  # function plug that will check if the project manager has already uploaded
  # a file with a given type before allowing the upload

  def file_type_exists?(conn, _) do
    %{"project_id" => project_id, "document" => %{"name" => contract_type}} = conn.params

    project_document = Repo.get_by(Document, name: contract_type, project_id: project_id)

    case project_document do
      nil -> conn
      _doc ->
        conn
        |> put_flash(:error, "You have already uploaded a #{contract_type} document")
        |> redirect(to: project_path(conn, :show, project_id))
        |> halt()
    end
  end

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

  def create(conn, %{"document" => %{"name" => name, "contract_name" => contract_name, "category" => category} = document_params, "project_id" => project_id}) do
    project = Repo.get_by(Project, id: project_id)
    if category == "" || (contract_name == "" && name == "") || !Map.has_key?(document_params, "file") do
      conn
      |> put_flash(:error, "File upload fields can't be empty!")
      |> redirect(to: project_path(conn, :show, project))
      |> halt()
    else
      %{"file" => file_params, "name" => name, "contract_name" => contract_name} = document_params
      document_name =
        case name == "" do
          true -> String.upcase(contract_name)
          false -> String.upcase(name)
        end

      document_params =
        Map.delete(document_params, "name")
        |> Map.put_new("name", document_name)
      case Document.is_pdf?(file_params) do
        false ->
          conn
          |> put_flash(:error, "Upload error, PDFs only")
          |> redirect(to: project_path(conn, :show, project))
        true ->
          updated_params =
            case S3.upload({:url, file_params}) do
              {:ok, :url, url} ->
                Map.delete(document_params, "file")
                |> Map.put_new("url", url)
              {:error, :url, _error} ->
                conn
                |> put_flash(:error, "Error uploading document!")
                |> redirect(to: project_path(conn, :show, project))
                document_params
            end
          changeset =
            project
            |> build_assoc(:documents)
            |> Document.changeset(updated_params)

          Repo.insert(changeset)
          conn
          |> put_flash(:info, "Document uploaded successfully.")
          |> redirect(to: project_path(conn, :show, project))
        end
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

    changeset =
      Repo.get!(Document, id)
      |> Ecto.Changeset.change
      |> Ecto.Changeset.no_assoc_constraint(:altered_documents)
      |> Repo.delete
      |> IO.inspect
    case changeset do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Document deleted successfully.")
        |> redirect(to: project_path(conn, :show, project))
      {:error, _} ->
        conn
        |> put_flash(:error, "You cannot delete a document after an offer has been accepted")
        |> redirect(to: project_path(conn, :show, project))
    end
  end
end
