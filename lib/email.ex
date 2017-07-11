defmodule Karma.Email do
  use Bamboo.Phoenix, view: Karma.EmailView

  alias Karma.{RedisCli, Controllers.Helpers}
  alias Karma.Router.Helpers, as: R_Helpers

  def send_text_email(recipient, subject, url, template, assigns \\ []) do
    new_email()
    |> to(recipient) # also needs to be a validated email
    |> from(System.get_env("ADMIN_EMAIL"))
    |> subject(subject)
    |> put_text_layout({Karma.LayoutView, "email.text"})
    |> render("#{template}.text", [url: url] ++ assigns)
  end

  def send_html_email(recipient, subject, url, template, assigns \\ []) do
    recipient
    |> send_text_email(subject, url, template, assigns)
    |> put_html_layout({Karma.LayoutView, "email.html"})
    |> render("#{template}.html", [url: url] ++ assigns)
  end

  def send_verification_email(user) do
    rand_string = Helpers.gen_rand_string(30)
    RedisCli.query(["SET", rand_string, user.email])
    url = "#{Helpers.get_base_url()}/verification/#{rand_string}"
    subject = "Karma - please verify your new account"
    send_html_email(user.email, subject, url, "verify", [first_name: user.first_name])
  end


  def send_reset_password_email(user, url) do
    rand_string = Helpers.gen_rand_string(30)
    RedisCli.query(["SET", rand_string, user.email])
    RedisCli.expire(rand_string, 60*5)
    url = url <> "?hash=#{rand_string}"
    send_html_email(user.email, "Karma - reset your password", url, "password_reset")
  end

  def send_new_offer_email(conn, offer, project) do
    {template, url} = case offer.user_id do
      nil ->
        hash_string = Helpers.gen_rand_string(30)
        RedisCli.query(["SET", hash_string, offer.target_email])
        RedisCli.query(["PERSIST", hash_string])
        {"new_offer_unregistered", R_Helpers.user_url(conn, :new, te: hash_string)} # user is not yet registered
      _ ->
        {"new_offer_registered", R_Helpers.project_offer_url(conn, :show, offer.project_id, offer)}
    end
    subject = "Karma - Invitation to join \"#{project.codename}\""
    send_html_email(offer.target_email, subject, url, template, [codename: project.codename])
  end

  def send_updated_offer_email(conn, offer, project) do
    template = "updated_offer"
    url = R_Helpers.project_offer_url(conn, :show, offer.project_id, offer)
    subject = "Karma - updated offer to join \"#{project.codename}\""
    send_html_email(offer.target_email,
    subject,
    url,
    template,
    [
      first_name: project.user.first_name,
      last_name: project.user.last_name,
      codename: project.codename
    ])
  end

  def send_offer_response_pm(conn, offer, project, contractor) do
    status =
      case offer.accepted do
        true -> "Accepted"
        false -> "Rejected"
      end
    template = "offer_response_pm"
    url = R_Helpers.project_offer_url(conn, :show, offer.project_id, offer)
    subject = "There has been a response to your offer!"
    send_html_email(project.user.email, subject, url, template, [offer_status: status, name_contractor: "#{contractor.first_name} #{contractor.last_name}", codename: project.codename, first_name: project.user.first_name])
  end

  def send_offer_accepted_contractor(conn, offer, user) do
    template = "offer_accepted_contractor"
    url = R_Helpers.project_offer_url(conn, :show, offer.project_id, offer)
    subject = "Congratulations! You have accepted an offer"
    send_html_email(offer.target_email, subject, url, template, [first_name: user.first_name, codename: offer.project.codename])
  end
end
