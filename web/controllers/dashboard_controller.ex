defmodule Karma.DashboardController do
  use Karma.Web, :controller

  alias Karma.Controllers.Helpers

  def index(conn, _params, user) do
    case user == nil do
      true ->
        conn
        |> redirect(to: session_path(conn, :new))
        |> halt()
      false ->
        projects =
          Repo.all(Helpers.user_projects(user))
          |> Repo.preload(:offers)
        offers =
          Repo.all(Helpers.user_offers(user))
          |> Repo.preload(:project)

        render conn, "index.html", projects: projects, offers: offers
    end
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

end
