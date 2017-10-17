defmodule Engine.DashboardController do
  use Engine.Web, :controller

  alias Engine.{Controllers.Helpers, Offer}

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
        query = from o in Offer,
          where: o.user_id == ^user.id,
          order_by: [desc: o.updated_at]
        offers = Repo.all(query) |> Repo.preload(:project) |> Repo.preload(:altered_documents)

        
        render conn, "index.html", projects: projects, offers: offers
    end
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

end
