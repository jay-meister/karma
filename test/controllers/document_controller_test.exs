defmodule Karma.DocumentControllerTest do
  use Karma.ConnCase

  import Mock

  alias Karma.Document
  @valid_attrs %{url: "some content", name: "NDA"}
  @invalid_attrs %{}

  setup do
    user = insert_user() # This represents the user that created the project (PM)
    project = insert_project(user)
    offer = insert_offer(project)
    conn = login_user(build_conn(), user)
    {:ok, conn: conn, user: user, project: project, offer: offer}
  end

  test "lists all entries on index", %{conn: conn, project: project} do
    conn = get conn, project_document_path(conn, :index, project)
    assert html_response(conn, 200) =~ "Listing documents"
  end

  test "renders form for new resources", %{conn: conn, project: project} do
    conn = get conn, project_document_path(conn, :new, project)
    assert html_response(conn, 200) =~ "New document"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, project: project} do
    file_upload = %Plug.Upload{path: "test/fixtures/foxy.png", filename: "foxy.png"}
    valid = Map.put(@valid_attrs, "file",  file_upload)

    with_mock ExAws, [request!: fn(_) -> %{status_code: 200} end] do
      conn = post conn, project_document_path(conn, :create, project), document: valid
      assert redirected_to(conn) == project_path(conn, :show, project)
      assert Repo.get_by(Document, @valid_attrs)
    end
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn, project: project} do
    file_upload = %Plug.Upload{path: "test/fixtures/foxy.png", filename: "foxy.png"}
    valid = Map.put(@valid_attrs, "file",  file_upload)

    with_mock ExAws, [request!: fn(_) -> %{status_code: 200} end] do
      conn = post conn, project_document_path(conn, :create, project), document: valid
      assert redirected_to(conn, 302) =~ "/projects/#{project.id}"
    end
  end

  test "error uploading file", %{conn: conn, project: project} do
    file_upload = %Plug.Upload{path: "", filename: ""}
    valid = Map.put(@valid_attrs, "file",  file_upload)

    with_mock ExAws, [request!: fn(_) -> %{status_code: 200} end] do
      conn = post conn, project_document_path(conn, :create, project), document: valid
      assert redirected_to(conn, 302) =~ "/projects/#{project.id}"
    end
  end

  test "bad changeset when uploading a file", %{conn: conn, project: project} do
    file_upload = %Plug.Upload{path: "test/fixtures/foxy.png", filename: "foxy.png"}
    invalid =
      Map.put(@valid_attrs, "file",  file_upload)
      |> Map.put("name", "")

    with_mock ExAws, [request!: fn(_) -> %{status_code: 200} end] do
      conn = post conn, project_document_path(conn, :create, project), document: invalid
      assert redirected_to(conn, 302) =~ "/projects/#{project.id}"
    end
  end

  test "shows chosen resource", %{conn: conn, project: project} do
    document = Repo.insert! %Document{project_id: project.id}
    conn = get conn, project_document_path(conn, :show, project, document)
    assert html_response(conn, 200) =~ "Show document"
  end

  test "renders page not found when id is nonexistent", %{conn: conn, project: project} do
    assert_error_sent 404, fn ->
      get conn, project_document_path(conn, :show, project, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn, project: project} do
    document = Repo.insert! %Document{}
    conn = get conn, project_document_path(conn, :edit, project, document)
    assert html_response(conn, 200) =~ "Edit document"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, project: project} do
    document = Repo.insert! %Document{}
    conn = put conn, project_document_path(conn, :update, project, document), document: Map.merge(@valid_attrs, %{category: "category"})
    assert redirected_to(conn) == project_document_path(conn, :show, project, document)
    assert Repo.get_by(Document, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, project: project} do
    document = Repo.insert! %Document{}
    conn = put conn, project_document_path(conn, :update, project, document), document: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit document"
  end

  test "deletes chosen resource", %{conn: conn, project: project} do
    document = Repo.insert! %Document{}
    conn = delete conn, project_document_path(conn, :delete, project, document)
    assert redirected_to(conn) == project_document_path(conn, :index, project)
    refute Repo.get(Document, document.id)
  end
end
