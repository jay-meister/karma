defmodule Karma.SignTest do
  use Karma.ConnCase
  alias Karma.{Sign, Signee}

  setup do
    user = insert_user() # This represents the user that created the project (PM)
    contractor = insert_user(%{email: "cont@gmail.com"})
    project = insert_project(user)
    offer = insert_offer(project)
    document = insert_document(project)
    signee1 = insert_signee(project, %{email: "signee1@gmail.com"})
    signee2 = insert_signee(project, %{email: "signee2@gmail.com"})
    signee3 = insert_signee(project, %{email: "signee3@gmail.com"})
    doc_sign1 = insert_document_signee(document, signee1, %{order: 2})
    doc_sign2 = insert_document_signee(document, signee2, %{order: 3})
    doc_sign3 = insert_document_signee(document, signee3, %{order: 1})
    conn = login_user(build_conn(), user)

    {:ok,
      conn: conn,
      user: user,
      project: project,
      offer: offer,
      document: document,
      contractor: contractor,
      signee1: signee1,
      signee2: signee2,
      doc_sign1: doc_sign1,
      doc_sign2: doc_sign2,
      doc_sign3: doc_sign3
    }
  end


  test "login function logs into the docusign api and returns a base_url" do
    {:ok, url} = Sign.login(Sign.headers())
    assert String.starts_with?(url, "https://demo.docusign.net/restapi/v2/accounts/")
  end

  test "login function fails with wrong credentials" do
    {:error, msg} = Sign.login([])
    assert msg == "Error logging into docusign"
  end


  test "get approval chain function", %{document: document, offer: offer} do
    alt_doc = insert_merged_document(document, offer)

    chain = Sign.get_approval_chain(alt_doc)

    # assert order is correct
    assert [
      %Signee{email: "signee3@gmail.com"},
      %Signee{email: "signee1@gmail.com"},
      %Signee{email: "signee2@gmail.com"}
      ] = chain
  end

  test "format approval chain function", %{document: document, offer: offer} do
    formatted = insert_merged_document(document, offer)
    |> Sign.get_approval_chain()
    |> Sign.format_approval_chain()

    assert hd(formatted) == %{email: "signee3@gmail.com", name: "John Smith"}
  end

  test "add index to chain function" do
    indexed = Sign.add_index_to_chain([%{name: "jack"}, %{name: "brad"}])
    assert hd(indexed) == %{name: "jack", recipientId: 1, routingOrder: 1}
  end
end
