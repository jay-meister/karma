defmodule Karma.OfferControllerTest do
  use Karma.ConnCase

  import Mock
  alias Karma.Offer
  @invalid_attrs default_offer(%{daily_or_weekly: "monthly"})


  setup do
    user = insert_user() # This represents the user that created the project (PM)
    project = insert_project(user)
    offer = insert_offer(project)
    conn = login_user(build_conn(), user)
    {:ok, conn: conn, user: user, project: project, offer: offer}
  end


  test "offers index: a PM can view the offers", %{conn: conn, offer: pending_offer, project: project} do
    accepted_offer = insert_offer(project, %{accepted: true, target_email: "email_1@gmail.com"})
    rejected_offer = insert_offer(project, %{accepted: false, target_email: "email_2@gmail.com"})

    conn1 = get conn, project_offer_path(conn, :index, pending_offer.project_id)
    assert html_response(conn1, 200) =~ pending_offer.target_email

    conn2 = get conn, project_offer_path(conn, :index, accepted_offer.project_id)
    assert html_response(conn2, 200) =~ accepted_offer.target_email

    conn3 = get conn, project_offer_path(conn, :index, rejected_offer.project_id)
    assert html_response(conn3, 200) =~ rejected_offer.target_email
  end

  test "renders form for new resources", %{conn: conn, offer: _offer, project: project} do
    conn = get conn, project_offer_path(conn, :new, project)
    assert html_response(conn, 200) =~ "Make new offer"
  end

  # if contractor not registered
  test "creates offer to an unregistered user and redirects them", %{conn: conn, project: project} do
    new_offer = default_offer(%{target_email: "different@test.com"})

    with_mock Karma.Mailer, [deliver_later: fn(email) ->
      assert email.html_body =~ "You have received an offer to work"
      assert email.html_body =~ "To review your offer please"
      assert email.to == new_offer.target_email
     end] do

      post_conn = post conn, project_offer_path(conn, :create, project), offer: new_offer
      assert redirected_to(post_conn) == project_offer_path(conn, :index, project)
      assert Phoenix.Controller.get_flash(post_conn, :info) =~ "Offer sent"

      # test the email is shown on the index view
      get_conn = get conn, project_offer_path(conn, :index, project)
      assert html_response(get_conn, 200) =~ new_offer.target_email
      assert Repo.get_by(Offer, target_email: new_offer.target_email)

      # ensure email was sent
      assert called Karma.Mailer.deliver_later(:_)
    end
  end

  # if contractor is already registered
  test "creates creates offer to a registered user", %{conn: conn, project: project} do

    contractor = insert_user(%{first_name: "Dave", last_name: "Seaman", email: "contractor@gmail.com"})
    new_offer = default_offer(%{target_email: "contractor@gmail.com"})

    with_mock Karma.Mailer, [deliver_later: fn(email) ->
      assert email.html_body =~ "You have received an offer to work"
      assert email.to == new_offer.target_email
     end] do

      post_conn = post conn, project_offer_path(conn, :create, project), offer: new_offer
      assert redirected_to(post_conn) == project_offer_path(conn, :index, project)
      assert Phoenix.Controller.get_flash(post_conn, :info) =~ "Offer sent"

      # test the contractor's email is shown on the index view
      get_conn = get conn, project_offer_path(conn, :index, project)
      assert html_response(get_conn, 200) =~ contractor.email
      offer = Repo.get_by(Offer, target_email: new_offer.target_email)

      # test the user has been linked to the offer
      assert offer.user_id == contractor.id

      # ensure email was sent
      assert called Karma.Mailer.deliver_later(:_)
    end
  end

  test "does not create offer and renders error if target_email is not given", %{conn: conn, project: project} do
    conn = post conn, project_offer_path(conn, :create, project), offer: default_offer(%{target_email: ""})
    assert html_response(conn, 200) =~ "can&#39;t be blank"
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, project: project} do
    conn = post conn, project_offer_path(conn, :create, project), offer: @invalid_attrs
    assert html_response(conn, 200) =~ "Make new offer"
  end

  test "does not create resource and renders errors when data is invalidd", %{conn: conn, project: project} do
    invalid = %{ default_offer() | contractor_details_accepted: "h" }
    conn = post conn, project_offer_path(conn, :create, project), offer: invalid
    assert html_response(conn, 200) =~ "Make new offer"
  end


  # test cant view offers for other projects not involved with
  test "offers show: user cannot view an offer of a project they did not create", %{offer: offer} do
    new_user = insert_user(%{email: "imposter@gmail.com"})

    conn = login_user(build_conn(), new_user)
    conn = get conn, project_offer_path(conn, :show, offer.project_id, offer)
    assert redirected_to(conn) == dashboard_path(conn, :index)
    assert Phoenix.Controller.get_flash(conn, :error) =~ "You do not have permission"
  end

  test "offers show: shows an offer to PM", %{conn: conn, offer: offer} do
    conn = get conn, project_offer_path(conn, :show, offer.project_id, offer)
    assert html_response(conn, 200) =~ offer.additional_notes
  end

  test "offers show: shows an offer to existing user", %{conn: conn, offer: offer} do
    user = insert_user(%{email: "a_new_email@gmail.com"})
    insert_startpack(%{user_id: user.id})
    conn = get conn, project_offer_path(conn, :show, offer.project_id, offer)
    assert html_response(conn, 200) =~ offer.additional_notes
  end

  test "renders page not found when id is nonexistent", %{conn: conn, project: project} do
    assert_error_sent 404, fn ->
      get conn, project_offer_path(conn, :show, project, -1)
    end
  end

  test "edit/update/delete offer forbidden if offer is not pending", %{conn: conn, project: proj} do
    accepted = insert_offer(proj, %{target_email: "different@gmail.com", accepted: false})

    Enum.each([
      get(conn, project_offer_path(conn, :edit, proj, accepted)),
      put(conn, project_offer_path(conn, :update, proj, accepted), offer: accepted),
      delete(conn, project_offer_path(conn, :delete, proj, accepted), offer: accepted)
    ], fn conn ->
      assert Phoenix.Controller.get_flash(conn, :error) =~ "You can only edit pending offers"
      assert redirected_to(conn) == project_offer_path(conn, :index, proj)
      assert conn.halted
    end)
  end

  test "renders form for editing if offer is still pending", %{conn: conn, offer: offer} do
    conn = get conn, project_offer_path(conn, :edit, offer.project_id, offer)
    assert html_response(conn, 200) =~ "Edit offer"
  end

  test "does not update offer or send email when data is valid but unchanged", %{conn: conn, offer: offer} do
    unchanged = default_offer()

    with_mock Karma.Mailer, [deliver_later: fn(_) -> nil end] do

      conn = put conn, project_offer_path(conn, :update, offer.project_id, offer), offer: unchanged
      assert Phoenix.Controller.get_flash(conn, :error) == "Nothing to update"

      # ensure email wasnt sent
      refute called Karma.Mailer.deliver_later(:_)
    end
  end


  test "updates offer and redirects when data is valid", %{conn: conn, offer: offer} do
    updated = default_offer(%{additional_notes: "Sneaky peaky"})

    with_mock Karma.Mailer, [deliver_later: fn(email) ->
      assert email.html_body =~ "Your offer to join"
      assert email.html_body =~ "The more information you add to Karma"
      assert email.to == updated.target_email
     end] do

      conn = put conn, project_offer_path(conn, :update, offer.project_id, offer), offer: updated
      assert redirected_to(conn) == project_offer_path(conn, :show, offer.project_id, offer)
      assert Repo.get_by(Offer, additional_notes: "Sneaky peaky")

      # ensure email was sent
      assert called Karma.Mailer.deliver_later(:_)
    end
  end


  test "cannot update offer and renders errors when data used in calculation is invalid", %{conn: conn, offer: offer, project: project} do
    conn = put conn, project_offer_path(conn, :update, project, offer), offer: @invalid_attrs
    assert html_response(conn, 200) =~ "Fee per day including holiday"
  end

  test "deletes chosen resource", %{conn: conn, offer: offer} do
    conn = delete conn, project_offer_path(conn, :delete, offer.project_id, offer)
    assert redirected_to(conn) == project_offer_path(conn, :index, offer.project_id)
    refute Repo.get(Offer, offer.id)
  end

  test "offer accepted", %{conn: conn, project: project, offer: offer} do
    with_mock Karma.Mailer, [deliver_later: fn(string) -> string end] do
      conn = put conn, project_offer_path(conn, :update, project, offer), offer: %{accepted: true}
      assert redirected_to(conn, 302) == "/projects/#{project.id}/offers/#{offer.id}"
    end
  end

  test "error responding to offer", %{conn: conn, project: project, offer: offer} do
    conn = put conn, project_offer_path(conn, :update, project, offer), offer: %{accepted: :invalid}
    assert redirected_to(conn, 302) == "/projects/#{project.id}/offers/#{offer.id}"
  end
end
