defmodule Karma.ProjectController do
  use Karma.Web, :controller

  alias Karma.{Project, LayoutView}


  plug :project_owner when action in [:show, :edit, :update, :delete]

  # project owner plug
  def project_owner(conn, _) do
    # if project doesn't exist, it should render a 404
    # if current user is owner of the project, add project to assigns
    # if current user is not owner, put permission flash, redirect and halt
    %{"id" => id} = conn.params
    user_id = conn.assigns.current_user.id
    case Repo.get(Project, id) do
      nil ->
        conn
        |> put_flash(:error, "Project could not be found")
        |> render(Karma.ErrorView, "404.html")
        |> halt()
      %Project{user_id: ^user_id} = project ->
        assign(conn, :project, project)
      %Project{} ->
        conn
        |> put_flash(:error, "You do not have permission to view that project")
        |> redirect(to: dashboard_path(conn, :index))
        |> halt()
    end
  end



  def index(conn, _params) do
    user = conn.assigns.current_user
    projects =
      Project
      |> Project.users_projects(user)
      |> Repo.all()

    render(conn, "index.html", projects: projects)
  end

  def new(conn, _params) do
    changeset = Project.changeset(%Project{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"project" => project_params}) do
    user = conn.assigns.current_user
    changeset =
      user
      |> build_assoc(:projects)
      |> Project.changeset(project_params)
    case Repo.insert(changeset) do
      {:ok, _project} ->
        conn
        |> put_flash(:info, "Project created successfully.")
        |> redirect(to: project_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end


  def show(conn, %{"id" => _id}) do
    render(conn, "show.html", project: conn.assigns.project)
  end

  def edit(conn, %{"id" => id}) do
    project = Repo.get!(Project, id)
    changeset = Project.changeset(project)
    render(conn, "edit.html", project: project, changeset: changeset)
  end

  def update(conn, %{"id" => id, "project" => project_params}) do
    project = Repo.get!(Project, id)
    changeset = Project.changeset(project, project_params)

    case Repo.update(changeset) do
      {:ok, project} ->
        conn
        |> put_flash(:info, "Project updated successfully.")
        |> redirect(to: project_path(conn, :show, project))
      {:error, changeset} ->
        render(conn, "edit.html", project: project, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Repo.get!(Project, id)

    Repo.delete!(project)

    conn
    |> put_flash(:info, "Project deleted successfully.")
    |> redirect(to: project_path(conn, :index))
  end
end
