defmodule Karma.Sign do

  # def new_envelope(_document, _path) do
  #   # login with docusign
  #   case login(headers()) do
  #     {:error, msg} ->
  #       {:error, msg}
  #     {:ok, base_url} ->
  #       base_url
  #       # download document from S3
  #       # get approval chain from db
  #       # build up envelope body
  #       # store envelope info from the response
  #       # return :ok
  #   end
  # end

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
