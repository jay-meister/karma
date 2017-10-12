defmodule Engine.OfferControllerTest do
  use Engine.ConnCase

  import Mock
  alias Engine.Offer
  @invalid_attrs default_offer(%{daily_or_weekly: "monthly", fee_per_day_inc_holiday: ""})


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
    assert html_response(conn1, 200) =~ pending_offer.recipient_fullname

    conn2 = get conn, project_offer_path(conn, :index, accepted_offer.project_id)
    assert html_response(conn2, 200) =~ accepted_offer.recipient_fullname

    conn3 = get conn, project_offer_path(conn, :index, rejected_offer.project_id)
    assert html_response(conn3, 200) =~ rejected_offer.recipient_fullname
  end

  test "renders form for new resources", %{conn: conn, offer: _offer, project: project} do
    insert_offer_custom_field(project)
    conn = get conn, project_offer_path(conn, :new, project)
    assert html_response(conn, 200) =~ "Make new offer"
  end

  # if contractor not registered
  test "creates offer to an unregistered user and redirects them", %{conn: conn, project: project} do
    new_offer = default_offer(%{target_email: "different@test.com"})

    # with_mock Engine.Mailer, [deliver_later: fn(email) ->
    #   assert email.html_body =~ "You've received an offer to work on the project"
    #   assert email.html_body =~ "To review the offer"
    #   assert email.to == new_offer.target_email
    #  end] do

      post_conn = post conn, project_offer_path(conn, :create, project), offer: new_offer
      [{_location, value}] = Enum.filter(post_conn.resp_headers, fn {name, _value} -> name == "location" end)
      offer_id = String.to_integer(List.last(String.split(value, "/")))
      assert redirected_to(post_conn) == project_offer_path(conn, :show, project, offer_id)
      assert Phoenix.Controller.get_flash(post_conn, :info) =~ "Offer saved"

      # test the email is shown on the index view
      get_conn = get conn, project_offer_path(conn, :index, project)
      assert html_response(get_conn, 200) =~ new_offer.recipient_fullname
      assert Repo.get_by(Offer, target_email: new_offer.target_email)

      # ensure email was sentt
    #   assert called Engine.Mailer.deliver_later(:_)
    # end
  end


  test "offer to unregistered user gets attached to user when they create an account", %{conn: conn} do
    # offer has been made, create an account with said user
    with_mock Engine.Mailer, [deliver_later: fn(_) -> nil end] do
      conn = post conn, user_path(conn, :create), user: default_user(%{email: "a_new_email@gmail.com"})
      assert redirected_to(conn) == session_path(conn, :new)
      user = Repo.get_by(Engine.User, email: "a_new_email@gmail.com")
      # ensure offer is attached to user
      offer = Repo.get_by(Offer, user_id: user.id)
      assert offer
    end
  end

  # if contractor is already registered
  test "creates creates offer to a registered user", %{conn: conn, project: project} do
    insert_offer_custom_field(project)
    contractor = insert_user(%{first_name: "Dave", last_name: "Seaman", email: "contractor@gmail.com"})
    new_offer = default_offer(%{target_email: "contractor@gmail.com", fee_per_day_inc_holiday: "200", recipient_fullname: "David Seamon"})

    # with_mock Engine.Mailer, [deliver_later: fn(email) ->
    #   assert email.html_body =~ "You've received an offer to work on the project"
    #   assert email.to == new_offer.target_email
    #  end] do

      post_conn = post conn, project_offer_path(conn, :create, project), offer: new_offer
      [{_location, value}] = Enum.filter(post_conn.resp_headers, fn {name, _value} -> name == "location" end)
      offer_id = String.to_integer(Enum.at(String.split(value, "/"), 4))
      assert redirected_to(post_conn) == project_offer_custom_field_path(conn, :add, project, offer_id)
      assert Phoenix.Controller.get_flash(post_conn, :info) =~ "Offer created, now complete your custom fields"

      # test the contractor's email is shown on the index view
      get_conn = get conn, project_offer_path(conn, :index, project)
      assert html_response(get_conn, 200) =~ contractor.first_name
      offer = Repo.get_by(Offer, target_email: new_offer.target_email)

      # test the user has been linked with the offer
      assert offer.user_id == contractor.id

      # ensure email was sent
      # assert called Engine.Mailer.deliver_later(:_)
    # end
  end

  test "does not create offer and renders error if target_email is not given", %{conn: conn, project: project} do
    conn = post conn, project_offer_path(conn, :create, project), offer: default_offer(%{target_email: ""})
    assert html_response(conn, 200) =~ "Response required"
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

  test "offers show: shows an offer to PM", %{conn: conn, offer: offer, project: project} do
    insert_project_custom_field(project)
    insert_offer_custom_field(project)
    conn = get conn, project_offer_path(conn, :show, offer.project_id, offer)
    assert html_response(conn, 200) =~ offer.additional_notes
  end

  test "offers show (PM): shows an offer to existing user", %{conn: conn, project: project} do
    user = insert_user(%{email: "contractor@gmail.com"})
    _startpack = update_startpack(user)
    offer = insert_offer(project, %{target_email: "contractor@gmail.com", user_id: user.id, accepted: true})
    insert_document(project, %{category: "Info"})
    conn = get conn, project_offer_path(conn, :show, offer.project_id, offer)
    assert html_response(conn, 200) =~ offer.additional_notes
  end


  test "offers show: contractor can view their offer", %{project: project} do
    user = insert_user(%{email: "contractor@gmail.com"})
    _startpack = update_startpack(user)

    conn = login_user(build_conn(), user)

    offer = insert_offer(project, %{target_email: "contractor@gmail.com", user_id: user.id})
    conn = get conn, project_offer_path(conn, :show, offer.project_id, offer)

    msg = "Complete your startpack to accept this offer"
    assert html_response(conn, 200) =~ offer.job_title
    assert html_response(conn, 200) =~ msg
  end

  test "renders page not found when id is nonexistent", %{conn: conn, project: project, offer: offer} do
    conn = assign(conn, :offer, offer)
    conn = get conn, project_offer_path(conn, :show, project, -1)
    assert html_response(conn, 200) =~ "Offer could not be found"
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

  test "renders form for editing if offer is still pending", %{conn: conn, offer: offer, project: project} do
    insert_project_custom_field(project)
    insert_offer_custom_field(project)
    conn = get conn, project_offer_path(conn, :edit, offer.project_id, offer)
    assert html_response(conn, 200) =~ "Edit offer"
  end

  test "replaces recipient_fullname with real name of contractor", %{conn: conn, project: project} do
    insert_user(%{email: "contractor@email.com"})
    offer = insert_offer(project, %{target_email: "contractor@email.com"})
    conn = get conn, project_offer_path(conn, :edit, offer.project_id, offer)
    assert html_response(conn, 200) =~ "Edit offer"
  end

  test "does not update offer or send email when data is valid but unchanged", %{conn: conn, offer: offer} do
    unchanged = default_offer()

    with_mock Engine.Mailer, [deliver_later: fn(_) -> nil end] do

      conn = put conn, project_offer_path(conn, :update, offer.project_id, offer), offer: unchanged
      assert Phoenix.Controller.get_flash(conn, :info) == "No changes made"

      # ensure email wasnt sent
      refute called Engine.Mailer.deliver_later(:_)
    end
  end


  test "updates offer and redirects to custom field when they exist", %{conn: conn, offer: offer, project: project, user: user} do
    updated = default_offer(%{additional_notes: "Sneaky peaky", user_id: user.id})
    insert_project_custom_field(project)
    insert_offer_custom_field(project)

    conn = put conn, project_offer_path(conn, :update, offer.project_id, offer), offer: updated
    assert redirected_to(conn) == project_offer_custom_field_path(conn, :add, offer.project_id, offer)
    assert Repo.get_by(Offer, additional_notes: "Sneaky peaky")

  end

  test "updates offer and redirects when data is valid", %{conn: conn, offer: offer, user: user} do
    updated = default_offer(%{additional_notes: "Sneaky peaky", user_id: user.id})

    conn = put conn, project_offer_path(conn, :update, offer.project_id, offer), offer: updated
    assert redirected_to(conn) == project_offer_path(conn, :show, offer.project_id, offer)
    assert Repo.get_by(Offer, additional_notes: "Sneaky peaky")

  end

  test "navigates to custom field page when no changes made", %{conn: conn, offer: offer, project: project} do
    insert_project_custom_field(project)
    insert_offer_custom_field(project)

    conn = put conn, project_offer_path(conn, :update, offer.project_id, offer), offer: %{}
    assert redirected_to(conn) == project_offer_custom_field_path(conn, :add, offer.project_id, offer)
  end

  test "updates offer and redirects when data is valid - nonexistent user", %{conn: conn, offer: offer} do
    updated = default_offer(%{additional_notes: "Sneaky peaky"})

    conn = put conn, project_offer_path(conn, :update, offer.project_id, offer), offer: updated
    assert redirected_to(conn) == project_offer_path(conn, :show, offer.project_id, offer)
    assert Repo.get_by(Offer, additional_notes: "Sneaky peaky")
  end


  test "cannot update offer and renders errors when data used in calculation is invalid", %{conn: conn, offer: offer, project: project} do
    conn = put conn, project_offer_path(conn, :update, project, offer), offer: @invalid_attrs
    assert html_response(conn, 200) =~ "Fee PER DAY including holiday"
  end

  test "deletes chosen resource", %{conn: conn, offer: offer} do
    conn = delete conn, project_offer_path(conn, :delete, offer.project_id, offer)
    assert redirected_to(conn) == project_offer_path(conn, :index, offer.project_id)
    refute Repo.get(Offer, offer.id)
  end

  test "offer can only be responded to by contractor", %{conn: conn, project: project, offer: offer} do
    conn = put conn, project_offer_path(conn, :response, project, offer), offer: %{accepted: true}
    assert Phoenix.Controller.get_flash(conn, :error) == "You do not have permission to respond to that offer"
    assert redirected_to(conn, 302) == "/"
  end

  test "offer rejected", %{project: project} do
    contractor = insert_user(%{email: "contractor@gmail.com"})
    offer = insert_offer(project, %{user_id: contractor.id, target_email: contractor.email})
    insert_document(project, %{name: offer.contract_type, url: "www.image_url"})
    insert_document(project, %{name: "LOAN OUT", url: "www.image_url"})
    conn = login_user(build_conn(), contractor)
    with_mock Engine.Mailer, [deliver_later: fn(string) -> string end] do
      conn = put conn, project_offer_path(conn, :response, project, offer), offer: %{accepted: false}
      assert redirected_to(conn, 302) == "/projects/#{project.id}/offers/#{offer.id}"
      assert Phoenix.Controller.get_flash(conn, :info) == "Offer rejected"
      # ensure the offer is now rejected in DB
      assert Repo.get(Engine.Offer, offer.id).accepted == false
    end
  end


  test "offer accepted, merged documents success", %{project: project} do
    contractor = insert_user(%{email: "contractor@gmail.com"})
    offer = insert_offer(project, %{user_id: contractor.id, target_email: "contractor@gmail.com"})
    update_startpack(contractor, %{use_loan_out_company?: true})
    insert_document(project, %{name: offer.contract_type, url: "www.image_url"})
    insert_document(project, %{name: "LOAN OUT", url: "www.image_url"})
    conn = login_user(build_conn(), contractor)
    with_mock Engine.Mailer, [deliver_later: fn(string) -> string end] do
      with_mock Engine.Merger, [merge_multiple: fn(_, _) -> {:ok, "Documents merged"} end] do
        conn = put conn, project_offer_path(conn, :response, project, offer), offer: %{accepted: true}
        assert redirected_to(conn, 302) == "/projects/#{project.id}/offers/#{offer.id}"
        assert Phoenix.Controller.get_flash(conn, :info) == "Congratulations, you have accepted this offer"
      end
    end
  end

  test "offer accepted, merged documents success - daily construction loan out", %{project: project} do
    contractor = insert_user(%{email: "contractor@gmail.com"})
    offer = insert_offer(project, %{user_id: contractor.id, target_email: "contractor@gmail.com", daily_or_weekly: "daily", department: "Construction"})
    update_startpack(contractor, %{use_loan_out_company?: true})
    insert_document(project, %{name: offer.contract_type, url: "www.image_url"})
    insert_document(project, %{name: "DAILY CONSTRUCTION LOAN OUT", url: "www.image_url"})
    conn = login_user(build_conn(), contractor)
    with_mock Engine.Mailer, [deliver_later: fn(string) -> string end] do
      with_mock Engine.Merger, [merge_multiple: fn(_, _) -> {:ok, "Documents merged"} end] do
        conn = put conn, project_offer_path(conn, :response, project, offer), offer: %{accepted: true}
        assert redirected_to(conn, 302) == "/projects/#{project.id}/offers/#{offer.id}"
        assert Phoenix.Controller.get_flash(conn, :info) == "Congratulations, you have accepted this offer"
      end
    end
  end

  test "offer accepted, merged documents success - daily transport loan out", %{project: project} do
    contractor = insert_user(%{email: "contractor@gmail.com"})
    offer = insert_offer(project, %{user_id: contractor.id, target_email: "contractor@gmail.com", daily_or_weekly: "daily", department: "Transport"})
    update_startpack(contractor, %{use_loan_out_company?: true})
    insert_document(project, %{name: offer.contract_type, url: "www.image_url"})
    insert_document(project, %{name: "DAILY TRANSPORT LOAN OUT", url: "www.image_url"})
    conn = login_user(build_conn(), contractor)
    with_mock Engine.Mailer, [deliver_later: fn(string) -> string end] do
      with_mock Engine.Merger, [merge_multiple: fn(_, _) -> {:ok, "Documents merged"} end] do
        conn = put conn, project_offer_path(conn, :response, project, offer), offer: %{accepted: true}
        assert redirected_to(conn, 302) == "/projects/#{project.id}/offers/#{offer.id}"
        assert Phoenix.Controller.get_flash(conn, :info) == "Congratulations, you have accepted this offer"
      end
    end
  end

  test "offer accepted, merged document failure", %{project: project} do
    contractor = insert_user(%{email: "contractor@gmail.com"})
    offer = insert_offer(project, %{user_id: contractor.id, target_email: "contractor@gmail.com"})
    update_startpack(contractor)
    insert_document(project, %{name: offer.contract_type, url: "www.image_url"})
    conn = login_user(build_conn(), contractor)
    with_mock Engine.Mailer, [deliver_later: fn(string) -> string end] do
      with_mock Engine.Merger, [merge_multiple: fn(_, _) -> {:error, "some flash message"} end] do
        conn = put conn, project_offer_path(conn, :response, project, offer), offer: %{accepted: true}
        assert redirected_to(conn, 302) == "/projects/#{project.id}/offers/#{offer.id}"
        # ensure offer is still not accepted
        assert Repo.get(Offer, offer.id).accepted == nil
      end
    end
  end

  test "offer accepted, but document doesn't exist", %{project: project} do
    contractor = insert_user(%{email: "contractor@gmail.com"})
    offer = insert_offer(project, %{user_id: contractor.id, target_email: contractor.email})
    conn = login_user(build_conn(), contractor)
    conn = put conn, project_offer_path(conn, :response, project, offer), offer: %{accepted: true}
    assert Phoenix.Controller.get_flash(conn, :error) == "There were no documents to merge your data with"
    assert redirected_to(conn, 302) == "/projects/#{project.id}/offers/#{offer.id}"
    # Ensure offer wasn't accepted on the DB
    assert Repo.get(Offer, offer.id).accepted == nil
  end

  test "error responding to offer", %{project: project} do
    contractor = insert_user(%{email: "contractor@gmail.com"})
    offer = insert_offer(project, %{user_id: contractor.id, target_email: contractor.email})
    insert_document(project, %{name: offer.contract_type, url: "www.image_url"})
    insert_document(project, %{name: "LOAN OUT", url: "www.image_url"})
    conn = login_user(build_conn(), contractor)
    conn = put conn, project_offer_path(conn, :response, project, offer), offer: %{accepted: :invalid}
    assert redirected_to(conn, 302) == "/projects/#{project.id}/offers/#{offer.id}"
    assert Phoenix.Controller.get_flash(conn, :error) == "Error making response"
  end


  test "get relevant documents for merge", %{offer: offer, project: project} do
    offer = %{offer | vehicle_allowance_per_week: 0}

    _contract = insert_document(project, %{name: "PAYE"})
    _box_rental_form = insert_document(project, %{name: "BOX RENTAL FORM"})
    _equipment_rental_form = insert_document(project, %{name: "EQUIPMENT RENTAL FORM"})
    _vehicle_allowance_form = insert_document(project, %{name: "VEHICLE ALLOWANCE"})

    query = Engine.Controllers.Helpers.get_forms_for_merging(offer)
    docs = Repo.all(query)

    document_names = docs |> Enum.map(&Map.get(&1, :name)) |> Enum.sort()

    # assert the correct forms are retrieved
    assert document_names == ["BOX RENTAL FORM", "EQUIPMENT RENTAL FORM", "PAYE"]
  end

  test "updates an offer email once send is clicked - unregistered user", %{conn: conn, offer: offer, project: project} do
    insert_offer_custom_field(project)
    insert_user(%{first_name: "Dave", last_name: "Seaman", email: "contractor@gmail.com"})

    with_mock Engine.Mailer, [deliver_later: fn(email) ->
      assert email.html_body =~ "Your offer to join"
      assert email.to == offer.target_email
     end] do

       conn = post conn, project_offer_path(conn, :send_offer, project, offer), offer: %{sent: true}
       assert Phoenix.Controller.get_flash(conn, :info) == "Offer updated successfully, and re-emailed to recipient"
       assert redirected_to(conn, 302) == project_offer_path(conn, :show, project, offer)

    # ensure email was sent
    assert called Engine.Mailer.deliver_later(:_)
    end
  end

  test "updates an offer email once send is clicked - registered user", %{conn: conn, project: project} do
    insert_offer_custom_field(project)
    contractor = insert_user(%{first_name: "Dave", last_name: "Seaman", email: "contractor@gmail.com"})
    offer = insert_offer(project, %{user_id: contractor.id})

    with_mock Engine.Mailer, [deliver_later: fn(email) ->
      assert email.html_body =~ "Your offer to join"
      assert email.to == offer.target_email
     end] do

       conn = post conn, project_offer_path(conn, :send_offer, project, offer), offer: %{sent: true}
       assert Phoenix.Controller.get_flash(conn, :info) == "Offer updated successfully, and re-emailed to recipient"
       assert redirected_to(conn, 302) == project_offer_path(conn, :show, project, offer)

    # ensure email was sent
    assert called Engine.Mailer.deliver_later(:_)
    end
  end

  test "sends an offer email once send is clicked - unregistered user", %{conn: conn, project: project} do
    unsent_offer = insert_offer(project, %{sent: false})
    insert_offer_custom_field(project)
    insert_user(%{first_name: "Dave", last_name: "Seaman", email: "contractor@gmail.com"})

    with_mock Engine.Mailer, [deliver_later: fn(email) ->
      assert email.html_body =~ "You've received an offer to work on the project"
      assert email.to == unsent_offer.target_email
     end] do

       conn = post conn, project_offer_path(conn, :send_offer, project, unsent_offer), offer: %{sent: true}
       assert Phoenix.Controller.get_flash(conn, :info) == "Offer sent to a_new_email@gmail.com"
       assert redirected_to(conn, 302) == project_offer_path(conn, :index, project)

    # ensure email was sent
    assert called Engine.Mailer.deliver_later(:_)
  end
  end

  test "sends an offer email once send is clicked - registered user", %{conn: conn, project: project} do
    insert_offer_custom_field(project)
    contractor = insert_user(%{first_name: "Dave", last_name: "Seaman", email: "contractor@gmail.com"})
    unsent_offer = insert_offer(project, %{sent: false, user_id: contractor.id})

    with_mock Engine.Mailer, [deliver_later: fn(email) ->
      assert email.html_body =~ "You've received an offer to work on the project"
      assert email.to == unsent_offer.target_email
     end] do

       conn = post conn, project_offer_path(conn, :send_offer, project, unsent_offer), offer: %{sent: true}
       assert Phoenix.Controller.get_flash(conn, :info) == "Offer sent to a_new_email@gmail.com"
       assert redirected_to(conn, 302) == project_offer_path(conn, :index, project)

      # ensure email was sent
      assert called Engine.Mailer.deliver_later(:_)
    end
  end

  test "doesn't send an offer if sent: false", %{conn: conn, project: project} do
    unsent_offer = insert_offer(project, %{sent: false})
    insert_offer_custom_field(project)
    insert_user(%{first_name: "Dave", last_name: "Seaman", email: "contractor@gmail.com"})

    conn = post conn, project_offer_path(conn, :send_offer, project, unsent_offer), offer: %{sent: false}
    assert Phoenix.Controller.get_flash(conn, :info) == "Offer saved"
    assert redirected_to(conn, 302) == project_offer_path(conn, :show, project, unsent_offer)
  end
end
