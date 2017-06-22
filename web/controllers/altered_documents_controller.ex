defmodule Karma.AlteredDocumentController do
  use Karma.Web, :controller
  alias Karma.{AlteredDocument, Sign}

  def sign(conn, %{"project_id" => p_id, "offer_id" => o_id, "id" => id}) do
    # get document

    altered = Repo.get(AlteredDocument, id)

    Sign.new_envelope(altered, conn.assigns.current_user)

    conn
    |> put_flash(:info, "document signed :)")
    |> redirect(to: project_offer_path(conn, :show, p_id, o_id))
  end

end
