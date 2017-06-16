defmodule Karma.Sign do

  def get_document do
    base_url = "https://demo.docusign.net/restapi/v2/accounts/3083537"
    uri = "/envelopes/f3d04e11-6e74-4dca-b689-5f60b5ae8649"
    url = base_url <> uri

    {:ok, res} = HTTPoison.get(url, headers(), [])
    body = Poison.decode!(res.body)
    recipients = base_url <> Map.get(body, "recipientsUri")
    notifications = base_url <> Map.get(body, "notificationUri")

    {:ok, res} = HTTPoison.get(recipients, headers(), [])
    IO.inspect "RECIPIENTS"
    IO.inspect res

  end

  def login do

    url = "https://demo.docusign.net/restapi/v2/login_information"
    {:ok, res} = HTTPoison.get(url, headers(), [])
    res = Poison.decode!(Map.from_struct(res).body)
    base_url = get_base_url(res)

    sign_request(base_url)
  end

  def sign_request(base_url) do
    IO.inspect base_url
    url = base_url <> "/envelopes"
    file = File.read!(System.cwd() <> "/test/fixtures/fillable.pdf")
    encoded = Base.encode64(file)
    body = Poison.encode!(%{
    	"emailSubject": "DocuSign test",
    	"emailBlurb": "Shows how to create and send an envelope from a document.",
    	"recipients": %{
    		"signers": [%{
    			"email": "jmurphy.web+1@gmail.com",
    			"name": "Jack Murphy",
    			"recipientId": "1",
    			"routingOrder": "1"
    		}, %{
    			"email": "murphy_626@hotmail.com",
    			"name": "Jack Murphy",
    			"recipientId": "2",
    			"routingOrder": "2"
    		}
      ]
    	},
    	"documents": [%{
    		"documentId": "1",
    		"name": "test.pdf",
    		"documentBase64": encoded
    	}] ,
    	"status": "sent",
      "eventNotification": %{
        "envelopeEvents": [
            %{ "envelopeEventStatusCode": "sent" },
            %{ "envelopeEventStatusCode": "completed" },
            %{ "envelopeEventStatusCode": "delivered" },
            %{ "envelopeEventStatusCode": "declined" },
            %{ "envelopeEventStatusCode": "voided" }
        ],
        # "includeDocuments": "true",
        "requireAcknowledgement": "true",
        "loggingEnabled": "true",
        "url": "https://ketgfdwsuq.localtunnel.me/DocusignEventListener/EnvelopeEvent"
      }
    })

    res = HTTPoison.post(url, body, headers(), [timeout: 100_000])
    IO.inspect res
  end


  def get_base_url (%{"loginAccounts" => accounts}) do
    # accounts is a list of accounts attached to our user
    # I do not know significance of the accounts so will just take the first one
    accounts
    |> hd()
    |> IO.inspect
    |> Map.get("baseUrl")
  end

  defp headers do
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
