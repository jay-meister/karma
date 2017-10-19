defmodule Engine.AdminDashboardController do
  use Engine.Web, :controller

  alias Engine.{Project, User}

  plug :authenticate_admin when action in [:index, :custom_fields, :users]

  def index(conn, _params) do
    render conn, "index.html"
  end

  def custom_fields(conn, _params) do
    all_projects =
      Repo.all(Project)
      |> Repo.preload(:custom_fields)

    render conn, "custom_fields.html", all_projects: all_projects
  end

  def users(conn, _params) do
    all_users = Repo.all(User)

    render conn, "users.html", all_users: all_users
  end

end
