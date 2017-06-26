defmodule Karma.Sign do
  import Ecto.Query

  alias Karma.{AlteredDocument, Repo}

  def new_envelope(merged, user) do
    # login with docusign
    case login(headers()) do
      {:error, msg} ->
        {:error, msg}
      {:ok, base_url} ->
        url = base_url <> "/envelopes"
        signers = get_and_prepare_approval_chain(merged, user)
        documents = get_and_prepare_document(merged, user)

        # build up envelope body
        body = build_envelope_body(documents, signers)
        |> Poison.encode!()

        case HTTPoison.post(url, body, headers(), recv_timeout: 10000) do
          {:ok, %HTTPoison.Response{body: body, headers: _headers, status_code: 201}} ->
            %{"envelopeId" => envelope_id} = Poison.decode!(body)
            altered =
              AlteredDocument.signing_started_changeset(merged, %{envelope_id: envelope_id})
              |> Repo.update!()
            {:ok, altered}
          _error ->
            {:error, "Error making signature request"}
        end
    end
  end


  # document related
  def get_and_prepare_document(merged, user) do
    # download file,
    case Karma.S3.get_object(merged.merged_url) do
      {:error, _error} ->
        {:error, "There was an error retrieving the document"}
      {:ok, file} ->
        original = Repo.get(Karma.Document, merged.document_id)

        # encode file, then prepare for docusign
        Base.encode64(file)
        |> prepare_document(merged, original, user)
    end
  end


  def prepare_document(encoded, merged, original, user) do
    [%{"documentId": merged.id,
       "name": "#{user.first_name}-#{user.last_name}-#{original.name}-#{merged.offer_id}.pdf",
       "documentBase64": encoded
    }]
  end


  # approval chain related
  def get_and_prepare_approval_chain(merged, contractor) do
    merged
    |> get_approval_chain()
    |> format_approval_chain()
    |> add_contractor_to_chain(contractor)
    |> add_index_to_chain()
  end

  def get_approval_chain(altered_document) do
    query = from s in Karma.Signee,
      join: ds in Karma.DocumentSignee,
      on: s.id == ds.signee_id,
      where: ds.document_id == ^altered_document.document_id,
      order_by: ds.order

    Repo.all(query)
  end

  def format_approval_chain(signees) do
    # format from signee struct to usable map (name and email keys)
    signees
    |> Enum.map(&Map.from_struct/1)
    |> Enum.map(&Map.take(&1, [:email, :name]))
  end

  def add_contractor_to_chain(chain, user) do
    user = %{email: user.email, name: "#{user.first_name} #{user.last_name}"}
    [user] ++ chain
  end


  def add_index_to_chain(chain) do
    chain
    |> Enum.with_index()
    |> Enum.map(fn({signee, index}) ->
        Map.merge(signee, %{"recipientId": index + 1, "routingOrder": index + 1})
      end)
  end

  # api related
  def login(headers) do
    url = Application.get_env(:karma, :docusign_login_url)
    case HTTPoison.get(url, headers, []) do
      {:ok, %{status_code: 200} = res} ->
        res = Poison.decode!(Map.from_struct(res).body)
        base_url = get_base_url(res)
        {:ok, base_url}
      _ ->
        {:error, "Error logging into docusign"}
    end
  end

  def get_base_url(%{"loginAccounts" => accounts}) do
    # accounts is a list of accounts attached to our user
    # I do not know significance of the accounts so will just take the first one
    accounts
    |> hd()
    |> Map.get("baseUrl")
  end

  def headers do
    auth = Poison.encode!(
      %{Username: System.get_env("DOCUSIGN_USERNAME"),
        Password: System.get_env("DOCUSIGN_PASSWORD"),
        IntegratorKey: System.get_env("DOCUSIGN_INTEGRATOR_KEY")
      })

    ["X-DocuSign-Authentication": auth,
     "Accept": "Application/json; Charset=utf-8",
     "Content-Type": "application/json"
    ]
  end

  def build_envelope_body(documents, chain) do
    %{
      "emailSubject": "Karma document sign",
      "emailBlurb": "Please sign the document using link provided.",
      "recipients": %{"signers": chain},
      "documents": documents,
      "status": "sent"
    }
  end
end
