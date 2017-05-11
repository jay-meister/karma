defmodule Karma.Email do
  use Bamboo.Phoenix, view: Karma.EmailView

  def send_email(recipient, subject, message) do
    new_email()
    |> to(recipient) # also needs to be a validated email
    |> from(System.get_env("ADMIN_EMAIL"))
    |> subject(subject)
    |> text_body(message)
  end

  def send_verification_email(user) do
    encoded_string = Base.hex_encode32(user.email, padding: false)
    message = "Follow the link below to verify your email address:
    http://localhost:4000/verification/#{encoded_string}"
    send_email(user.email, "Email Verification", message)
  end
end
