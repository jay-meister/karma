defmodule Engine.AdminDashboardController do
  use Engine.Web, :controller

  alias Engine.{Project}

  plug :authenticate_admin when action in [:index]

  def index(conn, _params) do
    all_projects =
      Repo.all(Project)
      |> Repo.preload(:custom_fields)

    render conn, "index.html", all_projects: all_projects
  end

end
