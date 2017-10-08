defmodule Engine.CustomFieldControllerTest do
  use Engine.ConnCase

  alias Engine.{CustomField}

  setup do
    mother_setup()
  end

  test "creates new custom project field", %{conn: conn, project: project} do
    project_custom_field = default_custom_field(%{type: "Project", value: "2 hours"})
    conn = post conn, project_custom_field_path(conn, :create, project), custom_field: project_custom_field
    assert Phoenix.Controller.get_flash(conn, :info) =~ "Custom field #{project_custom_field.name} created"
    assert redirected_to(conn, 302) == "/projects/#{project.id}"
  end

  test "creates new custom offer field", %{conn: conn, project: project} do
    offer_custom_field = default_custom_field()
    conn = post conn, project_custom_field_path(conn, :create, project), custom_field: offer_custom_field
    assert Phoenix.Controller.get_flash(conn, :info) =~ "Custom field #{offer_custom_field.name} created"
    assert redirected_to(conn, 302) == "/projects/#{project.id}"
  end

  test "redirects back to project view if changeset invalid", %{conn: conn, project: project} do
    offer_custom_field = %{name: "", type: "Project", value: ""}
    conn = post conn, project_custom_field_path(conn, :create, project), custom_field: offer_custom_field
    assert Phoenix.Controller.get_flash(conn, :error) =~ "Error creating custom field"
    assert redirected_to(conn, 302) == "/projects/#{project.id}"
  end

  test "delete a custom field", %{conn: conn, project: project} do
    custom_field = insert_offer_custom_field(project)
    conn = delete conn, project_custom_field_path(conn, :delete, project, custom_field)
    assert Phoenix.Controller.get_flash(conn, :info) == "Custom field deleted successfully"
    assert redirected_to(conn, 302) == "/projects/#{project.id}"
    assert Repo.get_by(CustomField, project_id: project.id) == nil
  end

  test "doesn't save a custom field to an offer if no value is given", %{conn: conn, project: project, offer: offer} do
    custom_field = insert_offer_custom_field(project)
    conn = post conn, project_offer_custom_field_path(conn, :save, project, offer, custom_field), custom_field: %{value: ""}
    assert Phoenix.Controller.get_flash(conn, :error) == "Oops! Make sure you entered a value"
    assert redirected_to(conn, 302) == "/projects/#{project.id}/offers/#{offer.id}/custom_fields/add"
  end

  test "saves a custom field to an offer", %{conn: conn, project: project, offer: offer} do
    custom_field = insert_offer_custom_field(project)
    conn = post conn, project_offer_custom_field_path(conn, :save, project, offer, custom_field), custom_field: %{name: "test", type: "Offer", value: "2 hours"}
    assert Phoenix.Controller.get_flash(conn, :info) == "Custom field test saved"
    assert redirected_to(conn, 302) == "/projects/#{project.id}/offers/#{offer.id}/custom_fields/add"
  end

  test "updates a custom field of an offer", %{conn: conn, project: project, offer: offer} do
    custom_field = insert_offer_custom_field(project)
    conn = post conn, project_offer_custom_field_path(conn, :revise, project, offer, custom_field), custom_field: %{value: "24 hours"}
    assert Phoenix.Controller.get_flash(conn, :info) == "Custom field #{custom_field.name} updated"
    assert redirected_to(conn, 302) == "/projects/#{project.id}/offers/#{offer.id}/custom_fields/add"
  end

  test "doesn't update a custom field when there is no value", %{conn: conn, project: project, offer: offer} do
    custom_field = insert_offer_custom_field(project)
    conn = post conn, project_offer_custom_field_path(conn, :revise, project, offer, custom_field), custom_field: %{value: ""}
    assert Phoenix.Controller.get_flash(conn, :error) == "Oops! Make sure you entered a value"
    assert redirected_to(conn, 302) == "/projects/#{project.id}/offers/#{offer.id}/custom_fields/add"
  end

  test "renders form for adding custom offer field values", %{conn: conn, project: project, offer: offer} do
    insert_project_custom_field(project)
    insert_project_custom_field(project, %{name: "Second project field"})
    insert_offer_custom_field(project)
    insert_offer_custom_field(project, %{name: "Second offer field"})
    insert_offer_custom_field(project, %{name: "Third offer field"})
    insert_associated_offer_custom_field(project, offer)
    insert_associated_offer_custom_field(project, offer, %{name: "Different name"})

    conn = get conn, project_offer_custom_field_path(conn, :add, project, offer)
    assert html_response(conn, 200) =~ "Custom offer fields"
  end





end
