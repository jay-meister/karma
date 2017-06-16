defmodule Karma.DashboardController do
  use Karma.Web, :controller

  alias Karma.Controllers.Helpers

  def docusign_event(conn, _params) do
    IO.inspect "inside event"
    bod = hd(tl(Tuple.to_list(Plug.Conn.read_body(conn))))
    IO.inspect bod

    parsed = Quinn.parse(bod)
    IO.inspect parsed
    json conn, %{}
  end

  def index(conn, _params) do
    user = conn.assigns.current_user
    case user == nil do
      true ->
        conn
        |> redirect(to: session_path(conn, :new))
        |> halt()
      false ->
        projects =
          Repo.all(Helpers.user_projects(user))
          |> Repo.preload(:offers)
        offers = Repo.all(Helpers.user_offers(user))
        Karma.Sign.login()
        render conn, "index.html", projects: projects, offers: offers
    end
  end
end
