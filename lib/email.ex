defmodule Karma.Email do
  use Bamboo.Phoenix, view: Karma.EmailView

  alias Karma.{RedisCli, Controllers.Helpers}

  def send_verification_text_email(recipient, subject, url) do
    new_email()
    |> to(recipient) # also needs to be a validated email
    |> from(System.get_env("ADMIN_EMAIL"))
    |> subject(subject)
    |> put_text_layout({Karma.LayoutView, "email.text"})
    |> render("verify.text", url: url)
  end

  def send_verification_html_email(recipient, subject, url) do
    recipient
    |> send_verification_text_email(subject, url)
    |> put_html_layout({Karma.LayoutView, "email.html"})
    |> render("verify.html", url: url)
  end

  def send_verification_email(user) do
    rand_string = Helpers.gen_rand_string(30)
    RedisCli.query(["SET", rand_string, user.email])
    dev_env? = Mix.env == :dev
    url =
    case dev_env? do
      true -> "#{System.get_env("DEV_URL")}/verification/#{rand_string}"
      false -> "#{System.get_env("PROD_URL")}/verification/#{rand_string}"
    end
    send_verification_html_email(user.email, "Email Verification", url)
  end

end
