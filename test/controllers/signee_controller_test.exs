defmodule Karma.SigneeControllerTest do
  use Karma.ConnCase

  @valid_attrs %{name: "First Last", email: "test@email.com", role: "Tester"}
  @invalid_attrs %{name: "", email: "", role: ""}

  setup do
    user = insert_user() # This represents the user that created the project (PM)
    project = insert_project(user)
    offer = insert_offer(project)
    conn = login_user(build_conn(), user)
    {:ok, conn: conn, user: user, project: project, offer: offer}
  end

  test "create new signee", %{conn: conn, project: project} do
    conn = post conn, project_signee_path(conn, :create, project), signee: @valid_attrs
    assert Phoenix.Controller.get_flash(conn, :info) == "First Last added as a signee to #{project.name}"
    assert redirected_to(conn, 302) == "/projects/#{project.id}"
  end

  test "create new signee fail", %{conn: conn, project: project} do
    conn = post conn, project_signee_path(conn, :create, project), signee: @invalid_attrs
    assert Phoenix.Controller.get_flash(conn, :error) =~ "Failed to add signee!"
    assert redirected_to(conn, 302) == "/projects/#{project.id}"
  end

  test "delete a signee", %{conn: conn, project: project} do
    signee = insert_signee(project)
    conn = delete conn, project_signee_path(conn, :delete, project, signee)
    assert Phoenix.Controller.get_flash(conn, :info) == "Signee deleted successfully."
    assert redirected_to(conn, 302) == "/projects/#{project.id}"
  end
end
