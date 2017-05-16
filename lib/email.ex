defmodule Karma.Email do
  use Bamboo.Phoenix, view: Karma.EmailView

  alias Karma.{RedisCli, Controllers.Helpers}

  def send_text_email(recipient, subject, url, template) do
    new_email()
    |> to(recipient) # also needs to be a validated email
    |> from(System.get_env("ADMIN_EMAIL"))
    |> subject(subject)
    |> put_text_layout({Karma.LayoutView, "email.text"})
    |> render("#{template}.text", url: url)
  end

  def send_html_email(recipient, subject, url, template) do
    recipient
    |> send_text_email(subject, url, template)
    |> put_html_layout({Karma.LayoutView, "email.html"})
    |> render("#{template}.html", url: url)
  end

  def send_verification_email(user) do
    rand_string = Helpers.gen_rand_string(30)
    RedisCli.query(["SET", rand_string, user.email])
    url = "#{Helpers.get_base_url()}/verification/#{rand_string}"
    send_html_email(user.email, "Email Verification", url, "verify")
  end


  def send_reset_password_email(user, url) do
    rand_string = Helpers.gen_rand_string(30)
    RedisCli.query(["SET", rand_string, user.email])
    RedisCli.expire(rand_string, 60*5)
    url = url <> "?hash=#{rand_string}"
    send_html_email(user.email, "Reset Password", url, "password_reset")
  end

end
