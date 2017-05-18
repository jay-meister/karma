defmodule Karma.OfferControllerTest do
  use Karma.ConnCase

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

  test "renders form for new resources", %{conn: conn, project: project} do
    conn = get conn, project_offer_path(conn, :new, project)
    assert html_response(conn, 200) =~ "New offer"
  end

  # if contractor not registered
  test "creates creates offer to an unregistered user and redirects them", %{conn: conn, project: project} do
    new_offer = default_offer(%{target_email: "different@test.com"})

    post_conn = post conn, project_offer_path(conn, :create, project), offer: new_offer
    assert redirected_to(post_conn) == project_offer_path(conn, :index, project)
    assert Phoenix.Controller.get_flash(post_conn, :info) =~ "Offer sent"

    # test the email is shown on the index view
    get_conn = get conn, project_offer_path(conn, :index, project)
    assert html_response(get_conn, 200) =~ new_offer.target_email
    assert Repo.get_by(Offer, target_email: new_offer.target_email)
  end

  # if contractor is already registered
  test "creates creates offer to a registered user", %{conn: conn, project: project} do
    contractor = insert_user(%{first_name: "Dave", last_name: "Seaman", email: "contractor@gmail.com"})
    new_offer = default_offer(%{target_email: "contractor@gmail.com"})

    post_conn = post conn, project_offer_path(conn, :create, project), offer: new_offer
    assert redirected_to(post_conn) == project_offer_path(conn, :index, project)
    assert Phoenix.Controller.get_flash(post_conn, :info) =~ "Offer sent"

    # test the contractor's email is shown on the index view
    get_conn = get conn, project_offer_path(conn, :index, project)
    assert html_response(get_conn, 200) =~ contractor.email
    offer = Repo.get_by(Offer, target_email: new_offer.target_email)

    # test the user has been linked to the offer
    assert offer.user_id == contractor.id
  end

  test "does not create offer and renders error if target_email is not given", %{conn: conn, project: project} do
    conn = post conn, project_offer_path(conn, :create, project), offer: default_offer(%{target_email: ""})
    assert html_response(conn, 200) =~ "can&#39;t be blank"
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, project: project} do
    conn = post conn, project_offer_path(conn, :create, project), offer: @invalid_attrs
    assert html_response(conn, 200) =~ "New offer"
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

  test "renders page not found when id is nonexistent", %{conn: conn, offer: _offer, project: _project} do
    assert_error_sent 404, fn ->
      get conn, project_offer_path(conn, :show, -1)
    end
  end

  test "editing offer forbidden if offer is not pending", %{conn: conn, offer: offer, project: project} do
    accepted_offer = insert_offer(project, %{target_email: "different@gmail.com", accepted: false})
    conn = get conn, project_offer_path(conn, :edit, offer.project_id, accepted_offer)
    assert Phoenix.Controller.get_flash(conn, :error) =~ "You can only edit pending offers"
    assert redirected_to(conn) == project_offer_path(conn, :index, project)
  end

  test "renders form for editing if offer is still pending", %{conn: conn, offer: offer} do
    conn = get conn, project_offer_path(conn, :edit, offer.project_id, offer)
    assert html_response(conn, 200) =~ "Edit offer"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, offer: _offer, project: _project} do
    offer = Repo.insert! %Offer{}
    conn = put conn, project_offer_path(conn, :update, 1, offer), offer: default_offer()
    assert redirected_to(conn) == project_offer_path(conn, :show, 1, offer)
    assert Repo.get_by(Offer, default_offer())
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, offer: _offer, project: _project} do
    offer = Repo.insert! %Offer{}
    conn = put conn, project_offer_path(conn, :update, 1, offer), offer: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit offer"
  end

  test "deletes chosen resource", %{conn: conn, offer: _offer, project: _project} do
    offer = Repo.insert! %Offer{}
    conn = delete conn, project_offer_path(conn, :delete, 1, offer)
    assert redirected_to(conn) == project_offer_path(conn, :index, 1)
    refute Repo.get(Offer, offer.id)
  end
end
