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

    chain = Sign.get_approval_chain(alt_doc, "Signee")

    # assert order is correct
    assert [
      %Signee{email: "signee3@gmail.com"},
      %Signee{email: "signee1@gmail.com"},
      %Signee{email: "signee2@gmail.com"}
      ] = chain
  end

  test "format approval chain function", %{document: document, offer: offer, signee3: signee3} do
    formatted =
      insert_merged_document(document, offer)
      |> Sign.get_approval_chain("Signee")
      |> Sign.format_approval_chain()

    assert hd(formatted) == %{email: "signee3@gmail.com", name: "John Smith", id: signee3.id}
  end

  test "add index to chain function" do
    merged = %{id: 333}
    chain = [%{name: "jack", id: 0}, %{name: "brad", id: 2}]
    indexed = Sign.add_index_to_chain(chain, merged)
    assert hd(indexed) == %{name: "jack", recipientId: 2, routingOrder: 2, tabs: %{signHereTabs: [%{documentId: 333, tabLabel: "signature_1\\*"}]}}
  end

  test "add agent to chain when not an agent deal" do
    chain = Sign.add_agent_to_chain_if_needed([], nil, %{agent_deal?: false})
    assert chain == []
  end

  test "get and prepare approval chain function", %{document: document, offer: offer,
    contractor: contractor, signee1: signee1, signee2: signee2, signee3: signee3} do
      agent_details = %{agent_deal?: true, agent_email_address: "agent@gmail.com", agent_name: "Secret Agent"}
      alt_doc = insert_merged_document(document, offer)
      _startpack = update_startpack(contractor, agent_details)
      contractor = Repo.preload(contractor, :startpacks, force: true)

      fully_formatted_chain =
        Sign.get_and_prepare_approval_chain(alt_doc, contractor)
        |> Enum.map(&Map.delete(&1, :tabs))

      assert fully_formatted_chain ==
        [%{email: "agent@gmail.com", name: "Secret Agent", recipientId: 1, routingOrder: 1},
         %{email: "cont@gmail.com", name: "Joe Blogs", recipientId: 2, routingOrder: 2},
         %{email: "signee3@gmail.com", name: "John Smith", recipientId: signee3.id + 2, routingOrder: 3},
         %{email: "signee1@gmail.com", name: "John Smith", recipientId: signee1.id + 2, routingOrder: 4},
         %{email: "signee2@gmail.com", name: "John Smith", recipientId: signee2.id + 2, routingOrder: 5}]
  end

  test "get_carbon_copies function", %{document: document, offer: offer,
    contractor: contractor, recipient_1: recipient_1} do
      agent_details = %{agent_deal?: false}
      alt_doc = insert_merged_document(document, offer)
      _startpack = update_startpack(contractor, agent_details)

      chain = ["signee", "signee", "signee", "signee"]

      carbon_copies = Sign.get_carbon_copies(alt_doc, chain)

      assert carbon_copies ==
        [%{email: recipient_1.email,
          name: recipient_1.name,
          recipientId: recipient_1.id + 2,
          routingOrder: Kernel.length(chain) + 2
        }]
  end

  # get document and prepare
  test "get and prepare document success", %{document: document, offer: offer, contractor: contractor} do
    alt_doc =
      insert_merged_document(document, offer)
      |> Map.put(:encoded_file, "YWFhYWFh")

      formatted_doc = Sign.prepare_document(alt_doc, contractor)
      assert "Joe-Blogs-PAYE-#{alt_doc.offer_id}.pdf" == formatted_doc.name
  end

  test "build_envelope_body" do
    envelope_body = Sign.build_envelope_body("templates")

    assert envelope_body == %{
      "emailSubject": "Karma document sign",
      "emailBlurb": "Please sign the document using link provided.",
      "compositeTemplates": "templates",
      "status": "sent"
    }
  end

  test "new_envelope success", %{user: user, document: document, offer: offer} do
    merged_document = insert_merged_document(document, offer)
    encoded = Poison.encode!(%{"loginAccounts" => [%{"baseUrl" => "oh_yeah"}]})
    with_mocks([
      {Karma.S3, [],
       [get_many_objects: fn(_) -> ["www.aws.someurl.pdf"] end]},
      {HTTPoison, [],
       [post: fn(_, _, _, _) -> {:ok, %HTTPoison.Response{body: encoded, headers: %{}, status_code: 201}} end,
       get: fn(_, _, _) -> {:ok, %HTTPoison.Response{status_code: 200}} end]},
     {Poison, [],
       [decode!: fn(_) -> %{"loginAccounts" => [%{"baseUrl" => "oh_yeah"}], "envelopeId" => "2"} end,
       encode!: fn(_) -> "encoded" end]}
    ]) do
      {:ok, _msg} = Karma.Sign.new_envelope([merged_document], user)
      assert Repo.get(AlteredDocument, merged_document.id).envelope_id
    end
  end

  test "new_envelope failure", %{user: user, document: document, offer: offer} do
    merged_document = insert_merged_document(document, offer)
    encoded = Poison.encode!(%{"loginAccounts" => [%{"baseUrl" => "oh_yeah"}]})
    with_mocks([
      {Karma.S3, [],
       [get_many_objects: fn(_) -> ["www.aws.someurl.pdf"] end]},
      {HTTPoison, [],
       [post: fn(_, _, _, _) -> {:error, %HTTPoison.Response{body: encoded, headers: %{}, status_code: 201}} end,
       get: fn(_, _, _) -> {:ok, %HTTPoison.Response{status_code: 200}} end]},
     {Poison, [],
       [decode!: fn(_) -> %{"loginAccounts" => [%{"baseUrl" => "oh_yeah"}], "envelopeId" => "2"} end,
       encode!: fn(_) -> "encoded" end]}
    ]) do
      {:error, _msg} = Karma.Sign.new_envelope([merged_document], user)
      refute Repo.get(AlteredDocument, merged_document.id).envelope_id
    end
  end
end
