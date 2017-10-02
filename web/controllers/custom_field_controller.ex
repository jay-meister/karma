defmodule Engine.CustomFieldController do
  use Engine.Web, :controller

  alias Engine.{CustomField}

  def create(conn, %{"project_id" => project_id, "custom_field" => %{"type" => type} = custom_field_params}, user) do
    project = Repo.get(user_projects(user), project_id)

    changeset =
      case type do
        "Project" ->
          project
          |> build_assoc(:custom_fields)
          |> CustomField.value_changeset(custom_field_params)
        _offer ->
          project
          |> build_assoc(:custom_fields)
          |> CustomField.changeset(custom_field_params)
      end

    case Repo.insert(changeset) do
      {:ok, custom_field} ->
        conn
        |> put_flash(:info, "Custom field #{custom_field.name} created")
        |> redirect(to: project_path(conn, :show, project))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Error creating custom field. Make sure you've entered a value for each field")
        |> redirect(to: project_path(conn, :show, project))
    end
  end

  def delete(conn, %{"id" => id, "project_id" => project_id}, user) do
    project = Repo.get(user_projects(user), project_id)
    custom_field = Repo.get!(CustomField, id)
    Repo.delete!(custom_field)
    conn
    |> put_flash(:info, "Custom field deleted successfully")
    |> redirect(to: project_path(conn, :show, project))
  end

  def add(conn, %{"project_id" => project_id, "offer_id" => offer_id}, user) do
    project = Repo.get(user_projects(user), project_id) |> Repo.preload(:custom_fields)
    IO.inspect project.custom_fields
    render conn, "add.html"
  end


  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end
end
