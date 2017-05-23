defmodule Karma.DashboardController do
  use Karma.Web, :controller

  def index(conn, _params, user) do
    case user == nil do
      true ->
        conn
        |> redirect(to: session_path(conn, :new))
        |> halt()
      false ->
        projects =
          Repo.all(user_projects(user))
          |> Repo.preload(:offers)
        offers = Repo.all(user_offers(user))
          
        render conn, "index.html", projects: projects, offers: offers
    end
  end

  defp user_offers(user) do
    assoc(user, :offers)
  end

  defp user_projects(user) do
    assoc(user, :projects)
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

end
