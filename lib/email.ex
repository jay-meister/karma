defmodule Karma.Email do
  use Bamboo.Phoenix, view: Karma.EmailView

  alias Karma.RedisCli

  def send_email(recipient, subject, message) do
    new_email()
    |> to(recipient) # also needs to be a validated email
    |> from(System.get_env("ADMIN_EMAIL"))
    |> subject(subject)
    |> text_body(message)
  end

  def send_verification_email(user) do
    rand_string = gen_rand_string(30)
    RedisCli.query(["SET", rand_string, user.email])
    dev_env? = Mix.env == :dev
    url =
    case dev_env? do
      true -> System.get_env("DEV_URL")
      false -> System.get_env("PROD_URL")
    end
    message = "Follow the link below to verify your email address:
    #{url}/verification/#{rand_string}"
    send_email(user.email, "Email Verification", message)
  end

  defp gen_rand_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end
end
