defmodule Engine.AlteredDocumentController do
  use Engine.Web, :controller
  alias Engine.{AlteredDocument, Sign, Offer}

  def sign(conn, %{"project_id" => p_id, "offer_id" => o_id}) do
    # get documents
    altered_docs = Repo.all(from ad in AlteredDocument, where: ad.offer_id == ^o_id)
    user = Repo.preload(conn.assigns.current_user, :startpacks)
    offer = Repo.get(Offer, o_id) |> Repo.preload(:project)
    # offer = Repo.preload(Offer, :projects)
    case Sign.new_envelope(altered_docs, user, offer) do
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
