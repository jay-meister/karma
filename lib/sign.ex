defmodule Karma.Sign do
  import Ecto.Query

  # def new_envelope(merged, user, _path) do
  #   # login with docusign
  #   case login(headers()) do
  #     {:error, msg} ->
  #       {:error, msg}
  #     {:ok, base_url} ->
  #       base_url
  #
  #       signers = get_and_prepare_approval_chain(merged, user)
  #       documents = get_and_prepare_document(merged)
  #       # download document from S3
  #       # get approval chain from db
  #       # build up envelope body
  #       # store envelope info from the response
  #       # return :ok
  #   end
  # end


  def get_and_prepare_approval_chain(merged, contractor) do
    merged
    |> get_approval_chain()
    |> format_approval_chain()
    |> add_contractor_to_chain(contractor)
    |> add_index_to_chain()
  end

  def add_index_to_chain(chain) do
    chain
    |> Enum.with_index()
    |> Enum.map(fn({signee, index}) ->
        Map.merge(signee, %{"recipientId": index + 1, "routingOrder": index + 1})
      end)
  end

  def add_contractor_to_chain(chain, user) do
    user = %{email: user.email, name: "#{user.first_name} #{user.last_name}"}
    [user] ++ chain
  end

  def format_approval_chain(signees) do
    # format from signee struct to usable map (name and email keys)
    signees
    |> Enum.map(&Map.from_struct/1)
    |> Enum.map(&Map.take(&1, [:email, :name]))
  end

  def get_approval_chain(altered_document) do
    query = from s in Karma.Signee,
      join: ds in Karma.DocumentSignee,
      on: s.id == ds.signee_id,
      where: ds.document_id == ^altered_document.document_id,
      order_by: ds.order

    Karma.Repo.all(query)
  end


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
end
