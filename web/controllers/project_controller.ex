defmodule Engine.ProjectController do
  use Engine.Web, :controller

  alias Engine.{Project, Document, Signee}


  plug :add_project_to_conn when action in [:show, :edit, :update, :delete]
  plug :block_if_not_project_manager when action in [:show, :edit, :update, :delete]


  # project owner plug
  def add_project_to_conn(conn, _) do
    # if project doesn't exist, it should render a 404
    # else add project to assigns
    project_id = case conn.params do
      %{"project_id" => project_id} -> project_id # if we are in an offers route
      %{"id" => project_id} -> project_id # if we are in a projects route
    end
    conn = assign(conn, :project, Repo.get(Project, project_id))

    case conn.assigns.project do
      nil ->
        conn
        |> put_flash(:error, "Project could not be found")
        |> render(Engine.ErrorView, "404.html")
        |> halt()
      _ ->
        is_pm? = conn.assigns.project.user_id == conn.assigns.current_user.id
        conn = assign(conn, :is_pm?, is_pm?)
        conn
    end
  end

  def block_if_not_project_manager(conn, _) do
    # block if current user is not PM
    case conn.assigns.is_pm? do
      false ->
        conn
        |> put_flash(:error, "You do not have permission to view that project")
        |> redirect(to: dashboard_path(conn, :index))
        |> halt()
      true ->
        conn
    end
  end

  def new(conn, _params) do
    changeset = Project.changeset(%Project{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"project" => project_params}) do
    %{"additional_notes" => notes} = project_params
    single_line_notes = Regex.replace(~r/\r\n/, notes, " ")
    project_params =
      project_params
      |> Map.delete("additional_notes")
      |> Map.put_new("additional_notes", single_line_notes)
    user = conn.assigns.current_user
    changeset =
      user
      |> build_assoc(:projects)
      |> Project.changeset(project_params)
    case Repo.insert(changeset) do
      {:ok, _project} ->
        conn
        |> put_flash(:info, "Project created successfully")
        |> redirect(to: dashboard_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end


  def show(conn, %{"id" => id}) do
    project = Repo.get(Project, id) |> Repo.preload(:documents)
    documents = project.documents
    forms = Enum.filter(documents, fn document -> document.category == "Form" end)
    deals = Enum.filter(documents, fn document -> document.category == "Deal" end)
    info = Enum.filter(documents, fn document -> document.category == "Info" end)
    signees = Repo.all(project_signees(project))
    document_changeset = Document.changeset(%Document{})
    signee_changeset = Signee.changeset(%Signee{})
    render(conn,
    "show.html",
    project: conn.assigns.project,
    document_changeset: document_changeset,
    signee_changeset: signee_changeset,
    forms: forms,
    deals: deals,
    signees: signees,
    info: info)
  end

  def edit(conn, %{"id" => id}) do
    project = Repo.get!(Project, id)
    changeset = Project.changeset(project)
    render(conn, "edit.html", project: project, changeset: changeset)
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    %{"additional_notes" => notes} = project_params
    single_line_notes = Regex.replace(~r/\r\n/, notes, " ")
    project_params =
      project_params
      |> Map.delete("additional_notes")
      |> Map.put_new("additional_notes", single_line_notes)
    project = Repo.get!(Project, id)
    changeset = Project.changeset(project, project_params)

    case Repo.update(changeset) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project updated successfully")
        |> redirect(to: project_path(conn, :show, project))
      {:error, changeset} ->
        render(conn, "edit.html", project: project, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Repo.get!(Project, id)

    Repo.delete!(project)

    conn
    |> put_flash(:info, "Project deleted successfully")
    |> redirect(to: project_path(conn, :index))
  end
end
