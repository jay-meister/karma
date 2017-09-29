defmodule Engine.ProjectControllerTest do
  use Engine.ConnCase

  alias Engine.Project

  setup do
    user = insert_user()
    project = insert_project(user)
    conn = login_user(build_conn(), user)
    {:ok, conn: conn, user: user, project: project}
  end


  test "all project paths require user to be logged in", %{project: project} do
    # Don't use the conn with logged in user
    conn = build_conn()
    Enum.each([
      get(conn, project_path(conn, :new)),
      post(conn, project_path(conn, :create)),
      get(conn, project_path(conn, :show, project)),
      get(conn, project_path(conn, :edit, project)),
      put(conn, project_path(conn, :update, project)),
      delete(conn, project_path(conn, :delete, project))
    ], fn conn ->
      assert redirected_to(conn, 302) == session_path(conn, :new)
      assert conn.halted
    end)
  end


  test "users can't touch other user's projects", %{conn: conn} do
    # add a different user and project to db
    # ensure the different user's project is not listed
    diff_user = insert_user(%{email: "different@test.com"})
    diff_project = insert_project(diff_user, %{name: "Different Movie"})

    Enum.each([
      get(conn, project_path(conn, :show, diff_project)),
      get(conn, project_path(conn, :edit, diff_project)),
      put(conn, project_path(conn, :update, diff_project)),
      delete(conn, project_path(conn, :delete, diff_project))
    ], fn conn ->
      assert redirected_to(conn, 302) == dashboard_path(conn, :index)
      assert Phoenix.Controller.get_flash(conn, :error) =~ "You do not have permission"
      assert conn.halted
    end)
  end

  test "/project/new renders form for new project", %{conn: conn} do
    conn = get conn, project_path(conn, :new)
    assert html_response(conn, 200) =~ "Create project"
  end

  test "post /project creates project and redirects when data is valid", %{conn: conn} do
    conn = post conn, project_path(conn, :create), project: default_project(%{name: "AAAA"})
    assert redirected_to(conn) == dashboard_path(conn, :index)
    assert Repo.get_by(Project, name: "AAAA")
  end

  test "/project/:id does not create project and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, project_path(conn, :create), project: %{additional_notes: ""}
    assert html_response(conn, 200) =~ "Create project"
  end

  test "/project/:id shows specific project", %{conn: conn, project: project} do
    conn = get conn, project_path(conn, :show, project)
    assert html_response(conn, 200) =~ project.codename
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    conn = get conn, project_path(conn, :show, -1)
    assert html_response(conn, 200) =~ "Project could not be found"
  end

  test "/projects/:id/edit renders form for editing chosen project", %{conn: conn, project: project} do
    conn = get conn, project_path(conn, :edit, project)
    assert html_response(conn, 200) =~ project.name
  end

  test "update /projects/:id updates project and redirects when data is valid", %{conn: conn, project: project} do
    updated_payload = %{default_project() | name: "A New Name"}

    conn = put conn, project_path(conn, :update, project), project: updated_payload
    assert redirected_to(conn) == project_path(conn, :show, project)

    # Check name was updated
    updated_project = Repo.get(Project, project.id)
    assert updated_project.name == "A New Name"
  end


  test "update /projects/:id does not update and renders errors when data is invalid", %{conn: conn, project: project} do
    invalid_attrs = %{default_project() | duration: "not a number!"}
    conn = put conn, project_path(conn, :update, project), project: invalid_attrs
    assert html_response(conn, 200) =~ "Edit project"
  end

  test "delete /projects/:id chosen project", %{conn: conn, project: project} do
    conn = delete conn, project_path(conn, :delete, project)
    assert redirected_to(conn) == project_path(conn, :index)
    refute Repo.get(Project, project.id)
  end
end
