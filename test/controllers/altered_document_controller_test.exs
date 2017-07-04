defmodule Karma.AlteredDocumentControllerTest do
  use Karma.ConnCase

  alias Karma.{Sign}

  import Mock

  setup do
    mother_setup()
  end

  test "sign success", %{conn: conn, project: project, offer: offer, document: document} do
    _altered_document = insert_merged_document(document, offer)
    with_mock Sign, [new_envelope: fn(_, _) -> {:ok, "document"} end] do
      conn = get conn, project_offer_altered_document_path(conn, :sign, project, offer)
      assert Phoenix.Controller.get_flash(conn, :info) =~ "Document sent to signees"
      assert redirected_to(conn, 302) == "/projects/#{project.id}/offers/#{offer.id}"
    end
  end

  test "sign failure", %{conn: conn, project: project, offer: offer, document: document} do
    _altered_document = insert_merged_document(document, offer)
    with_mock Sign, [new_envelope: fn(_, _) -> {:error, "Error sending document"} end] do
      conn = get conn, project_offer_altered_document_path(conn, :sign, project, offer)
      assert Phoenix.Controller.get_flash(conn, :error) =~ "Error sending document"
      assert redirected_to(conn, 302) == "/projects/#{project.id}/offers/#{offer.id}"
    end
  end
end
