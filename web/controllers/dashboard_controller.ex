defmodule Karma.DashboardController do
  use Karma.Web, :controller

  plug :authenticate when action in [:index]

  def index(conn, _params, user) do
    projects = Repo.all(user_projects(user))
    render conn, "index.html", projects: projects
  end

  defp user_projects(user) do
    assoc(user, :projects)
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

end
