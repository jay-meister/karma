defmodule Karma.AlteredDocumentController do
  use Karma.Web, :controller
  alias Karma.{AlteredDocument, Sign}

  def sign(conn, %{"project_id" => p_id, "offer_id" => o_id, "id" => _id}) do
    # get document

    # altered = Repo.get(AlteredDocument, id)

    altered_docs = Repo.all(from ad in AlteredDocument, where: ad.offer_id == ^o_id)

    case Sign.new_envelope(altered_docs, conn.assigns.current_user) do
      {:ok, _msg} ->
        conn
        |> put_flash(:info, "Document sent to signees")
        |> redirect(to: project_offer_path(conn, :show, p_id, o_id))
      {:error, msg} ->
        conn
        |> put_flash(:error, msg)
        |> redirect(to: project_offer_path(conn, :show, p_id, o_id))
    end
  end
end
