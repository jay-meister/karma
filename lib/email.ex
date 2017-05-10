defmodule Karma.Email do
  use Bamboo.Phoenix, view: Karma.EmailView

  def send_email(recipient, subject, message) do
    new_email()
    |> to(recipient) # also needs to be a validated email
    |> from(System.get_env("TARGET_EMAIL"))
    |> subject(subject)
    |> text_body(message)
  end

  def send_verification_email(user) do
    IO.inspect user
    encoded_string =
      user.id
      |> Cipher.encrypt
    IO.inspect encoded_string
    message = "Follow the link below to verify your email address: "
    send_email(user.email, "Email Verification", message)
  end
end
