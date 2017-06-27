defmodule Karma.SignTest do
  use Karma.ConnCase
  alias Karma.{Sign, Signee, AlteredDocument}

  import Mock

  setup do
    mother_setup()
  end


  test "login function logs into the docusign api and returns a base_url" do
    {:ok, url} = Sign.login(Sign.headers())
    assert String.starts_with?(url, "https://demo.docusign.net/restapi/v2/accounts/")
  end

  test "login function fails with wrong credentials" do
    {:error, msg} = Sign.login([])
    assert msg == "Error logging into docusign"
  end


  # get approval chain and format
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
    formatted =
      insert_merged_document(document, offer)
      |> Sign.get_approval_chain()
      |> Sign.format_approval_chain()

    assert hd(formatted) == %{email: "signee3@gmail.com", name: "John Smith"}
  end
  test "add index to chain function" do
    indexed = Sign.add_index_to_chain([%{name: "jack"}, %{name: "brad"}])
    assert hd(indexed) == %{name: "jack", recipientId: 1, routingOrder: 1}
  end
  test "get and prepare approval chain function", %{document: document, offer: offer, contractor: contractor} do
    alt_doc = insert_merged_document(document, offer)

    fully_formatted_chain = Sign.get_and_prepare_approval_chain(alt_doc, contractor)
    assert fully_formatted_chain ==
      [%{email: "cont@gmail.com", name: "Joe Blogs", recipientId: 1, routingOrder: 1},
       %{email: "signee3@gmail.com", name: "John Smith", recipientId: 2, routingOrder: 2},
       %{email: "signee1@gmail.com", name: "John Smith", recipientId: 3, routingOrder: 3},
       %{email: "signee2@gmail.com", name: "John Smith", recipientId: 4, routingOrder: 4}]

  end



  # get document and prepare
  test "get and prepare document success", %{document: document, offer: offer, contractor: contractor} do
    alt_doc = insert_merged_document(document, offer)

    with_mock Karma.S3, [get_object: fn(_) ->
      {:ok, System.cwd()<>"/test/fixtures/fillable.pdf"}
    end] do
      formatted_doc = Sign.get_and_prepare_document(alt_doc, contractor)
      assert "Joe-Blogs-PAYE-#{alt_doc.offer_id}.pdf" == hd(formatted_doc).name
    end
  end

  test "build_envelope_body" do
    chain = %{
      signee_1: "Signee 1",
      signee_2: "Signee 2",
    }
    envelope_body = Sign.build_envelope_body(["doc1", "doc2"], chain)

    assert envelope_body == %{
      "emailSubject": "Karma document sign",
      "emailBlurb": "Please sign the document using link provided.",
      "recipients": %{
        "signers": %{
          signee_1: "Signee 1",
          signee_2: "Signee 2",
        }
      },
      "documents": ["doc1", "doc2"],
      "status": "sent"
    }
  end

  test "new_envelope", %{user: user, document: document, offer: offer} do
    merged_document = insert_merged_document(document, offer)
    encoded = Poison.encode!(%{"loginAccounts" => [%{"baseUrl" => "oh_yeah"}]})
    with_mocks([
      {Karma.S3, [],
       [get_object: fn(_) -> {:ok, "www.aws.someurl.pdf"} end]},
      {HTTPoison, [],
       [post: fn(_, _, _, _) -> {:ok, %HTTPoison.Response{body: encoded, headers: %{}, status_code: 201}} end,
       get: fn(_, _, _) -> {:ok, %HTTPoison.Response{status_code: 200}} end]},
     {Poison, [],
       [decode!: fn(_) -> %{"loginAccounts" => [%{"baseUrl" => "oh_yeah"}], "envelopeId" => "2"} end,
       encode!: fn(_) -> "encoded" end]}
    ]) do
      {:ok, altered_document} = Karma.Sign.new_envelope(merged_document, user)
      refute Repo.get_by(AlteredDocument, envelope_id: altered_document.envelope_id) == nil
    end
  end
end
