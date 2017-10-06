defmodule Engine.DashboardController do
  use Engine.Web, :controller

  alias Engine.Controllers.Helpers

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
          |> Enum.filter(fn offer -> offer.sent == true end)
          |> Enum.sort(&(&1.updated_at >= &2.updated_at))

        render conn, "index.html", projects: projects, offers: offers
    end
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

end
