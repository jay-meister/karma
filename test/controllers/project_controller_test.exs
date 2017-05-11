defmodule Karma.ProjectControllerTest do
  use Karma.ConnCase

  alias Karma.Project
  @valid_attrs %{ active: true,
    additional_notes: "some content",
    budget: "high",
    codename: "Finickity Spicket",
    company_address_1: "some content",
    company_address_2: "some content",
    company_address_3: "some content",
    company_address_4: "some content",
    company_address_5: "some content",
    company_name: "some content",
    description: "some content",
    duration: 12,
    holiday_rate: "0.1077",
    locations: "London, Paris",
    name: "Mission Impossible 10",
    operating_base_address_1: "some content",
    operating_base_address_2: "some content",
    operating_base_address_3: "some content",
    operating_base_address_4: "some content",
    operating_base_address_5: "some content",
    start_date: %{"day" => 1, "month" => 1, "year" => 2019},
    studio_name: "some content",
    type: "some content"
  }

  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, project_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing projects"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, project_path(conn, :new)
    assert html_response(conn, 200) =~ "New project"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, project_path(conn, :create), project: @valid_attrs
    # assert redirected_to(conn) == project_path(conn, :index)
    # assert Repo.get_by(Project, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, project_path(conn, :create), project: @invalid_attrs
    assert html_response(conn, 200) =~ "New project"
  end

  test "shows chosen resource", %{conn: conn} do
    project = Repo.insert! %Project{}
    conn = get conn, project_path(conn, :show, project)
    assert html_response(conn, 200) =~ "Show project"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, project_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    project = Repo.insert! %Project{}
    conn = get conn, project_path(conn, :edit, project)
    assert html_response(conn, 200) =~ "Edit project"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    project = Repo.insert! %Project{}
    conn = put conn, project_path(conn, :update, project), project: @valid_attrs
    assert redirected_to(conn) == project_path(conn, :show, project)
    assert Repo.get_by(Project, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    project = Repo.insert! %Project{}
    conn = put conn, project_path(conn, :update, project), project: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit project"
  end

  test "deletes chosen resource", %{conn: conn} do
    project = Repo.insert! %Project{}
    conn = delete conn, project_path(conn, :delete, project)
    assert redirected_to(conn) == project_path(conn, :index)
    refute Repo.get(Project, project.id)
  end
end
