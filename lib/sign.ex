defmodule Engine.Sign do
  import Ecto.Query

  alias Engine.{AlteredDocument, Repo, S3}

  @default_increment 2
  # when creating an approval chain, we 'inject' the agent if necessary
  # and the contractor to the beginning of the signee list
  # which means we need to increment all signee ids by 2

  def new_envelope(altered_docs, user, offer) do
    # login with docusign
    case login(headers()) do
      {:error, msg} ->
        {:error, msg}
      {:ok, base_url} ->
        url = base_url <> "/envelopes"
        blurb_and_subject = get_email_blurb_and_subject(user, offer)

        body =
          altered_docs
          # download the files from S3, encode and add them to the array
          |> add_encoded_file_to_docs()
          # add index so we can sequence documents
          |> Enum.with_index()
          # build documents into composite templates
          |> Enum.map(&get_composite_template(&1, user, offer))
          # attach templates to the body
          |> build_envelope_body(blurb_and_subject)
          |> Poison.encode!()

        case HTTPoison.post(url, body, headers(), recv_timeout: 40000) do
          {:ok, %HTTPoison.Response{body: body, headers: _headers, status_code: 201}} ->
            %{"envelopeId" => envelope_id} = Poison.decode!(body)
            [%{offer_id: offer_id} | _t] = altered_docs

            AlteredDocument.set_documents_to_signing(offer_id, envelope_id)
            |> Repo.update_all([])

            {:ok, "success"}
          _error ->
            {:error, "Error making signature request"}
        end
    end
  end

  def get_composite_template({merged, index}, user, offer) do
    signers = get_and_prepare_approval_chain(merged, user)

    %{"inlineTemplates": [
      %{"sequence": Integer.to_string(index + 1),
        "recipients": %{
          "signers": signers,
          "carbonCopies": get_carbon_copies(merged, signers)
        }
      }
      ],
      "document": prepare_document(merged, user, offer)
    }
  end
  def add_encoded_file_to_docs(altered_docs) do
    # download the merged documents from the urls
    altered_docs
    |> Enum.map(fn(doc) -> doc.merged_url end)
    |> S3.get_many_objects()
    |> Enum.zip(altered_docs)
    |> Enum.map(fn({file, doc}) ->
        Map.merge(Map.from_struct(doc), %{encoded_file: Base.encode64(file)})
      end)
  end

  def prepare_document(merged, user, offer) do
    # 'User_first_name User_last_name, Offer_job_title (Offer_department) - Offer_daily_or_weekly, Offer_contract_type'
    original = Repo.get(Engine.Document, merged.document_id)
    %{"documentId": merged.id,
       "name": "#{String.upcase(user.first_name)} #{String.upcase(user.last_name)}, #{offer.job_title} (#{offer.department}) - #{String.upcase(offer.daily_or_weekly)}, #{original.name}.pdf",
       "documentBase64": merged.encoded_file,
       "transformPdfFields": "true"
    }
  end


  # approval chain related
  def get_and_prepare_approval_chain(merged, contractor) do
    get_approval_chain(merged, "Approver")
    |> format_approval_chain()
    |> add_contractor_to_chain(contractor)
    |> add_index_to_chain(merged)
    |> add_agent_to_chain_if_needed(merged, contractor.startpacks)
  end

  def get_approval_chain(original, approver_type) do
    query = from s in Engine.Signee,
      join: ds in Engine.DocumentSignee,
      on: s.id == ds.signee_id,
      where: ds.document_id == ^original.document_id
      and s.approver_type == ^approver_type,
      order_by: ds.order

    Repo.all(query)
  end

  def format_approval_chain(signees) do
    # format from signee struct to usable map (name and email keys)
    signees
    |> Enum.map(&Map.from_struct/1)
    |> Enum.map(&Map.take(&1, [:email, :name, :id]))
  end

  def add_contractor_to_chain(chain, user) do
    user = %{email: user.email, name: "#{user.first_name} #{user.last_name}", id: 0}
    [user] ++ chain
  end

  def add_index_to_chain(chain, merged, increment \\ @default_increment) do
    # contractor has id set to 0, signees have id set to their signee id on our table
    # add 2 to this id, so contractors id will become 2, required to be positive by docusign
    # if an agent is to be added, they will be added at index 1
    chain
    |> Enum.with_index()
    |> Enum.map(fn({signee, index}) ->
        signing_index = index + 1
        routing_index = index + increment
        tabs = %{
          "signHereTabs": [
            %{documentId: merged.id, "tabLabel": "signature_#{signing_index}\\*"}
          ],
          "dateSignedTabs": [
            %{documentId: merged.id, "tabLabel": "date_signed_#{signing_index}DocuSignDateSigned\\*"}
          ]
        }
        additional = %{"recipientId": signee.id + @default_increment, "routingOrder": routing_index, "tabs": tabs}
        Map.merge(signee, additional)
      end)
    |> Enum.map(&Map.delete(&1, :id))
  end

  def get_carbon_copies(merged, chain) do
    increment = Kernel.length(chain) + @default_increment
    # we want to increment the routing order of the recipients by the length of the chain plus the 2
    get_approval_chain(merged, "Recipient")
    |> format_approval_chain()
    |> add_index_to_chain(merged, increment)
    |> Enum.map(&Map.drop(&1, [:id, :tabs]))
  end

  def add_agent_to_chain_if_needed(chain, merged, startpack) do
    case startpack.agent_deal? do
      false ->
        chain
      true ->
        tabs =
          %{"initialHereTabs": [
            %{documentId: merged.id, "tabLabel": "agent_initials\\*"}
          ]}
        agent =
          %{tabs: tabs,
            name: startpack.agent_name,
            email: startpack.agent_email_address,
            recipientId: 1,
            routingOrder: 1
        }
        List.insert_at(chain, 0, agent)
    end
  end

  # api related
  def login(headers) do
    url = Application.get_env(:engine, Engine.Sign)[:url]
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
      %{Username: Application.get_env(:engine, Engine.Sign)[:username],
        Password: Application.get_env(:engine, Engine.Sign)[:password],
        IntegratorKey: Application.get_env(:engine, Engine.Sign)[:integrator_key]
      })

    ["X-DocuSign-Authentication": auth,
     "Accept": "Application/json; Charset=utf-8",
     "Content-Type": "application/json"
    ]
  end

  # Project_codename - for signature: User_first_name User_last_name, Offer_job_title (Offer_department)
  def build_envelope_body(templates, blurb_and_sub) do
    body = %{
      "compositeTemplates": templates,
      "status": "sent"
    }
    Map.merge(blurb_and_sub, body)
  end

  def get_email_blurb_and_subject(user, offer) do
    # Project_codename - agreement: User_first_name User_last_name, Offer_job_title (Offer_department)
    sub = "#{offer.project.codename} - agreement: #{user.first_name} #{user.last_name}, #{offer.job_title} (#{offer.department})"

    %{"emailSubject": sub,
      "emailBlurb": "\n\n" <> sub
    }
  end
end
