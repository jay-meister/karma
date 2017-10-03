defmodule Engine.CustomFieldController do
  use Engine.Web, :controller
  alias Engine.{CustomField, Offer}

  plug :authenticate when action in [:create, :delete, :add]

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
    changeset = CustomField.value_changeset(%CustomField{})
    custom_offer_fields = Enum.filter(project.custom_fields, fn field -> field.type == "Offer" end)
    empty_fields =
      custom_offer_fields
      |> Enum.filter(fn field -> field.value == nil end)
      |> Enum.count()
    IO.inspect empty_fields
    offer_changeset = Offer.send_offer_changeset(%Offer{})

    render conn, "add.html",
    changeset: changeset,
    custom_offer_fields: custom_offer_fields,
    project_id: project_id,
    offer_id: offer_id,
    empty_fields: empty_fields,
    offer_changeset: offer_changeset
  end

  def save(conn, %{"project_id" => project_id, "offer_id" => offer_id, "id" => id, "custom_field" => custom_field_params} = params, user) do
    custom_field = Repo.get!(CustomField, id)
    IO.inspect custom_field_params
    changeset = CustomField.value_changeset(custom_field, custom_field_params)

    new =
      custom_field_params
      |> Map.put_new("project_id", project_id)
      |> Map.put_new("offer_id", offer_id)
      |> Map.put_new("type", "Offer")

    new_changeset = CustomField.value_changeset(%CustomField{}, new)
    IO.inspect new
    IO.inspect new_changeset

    case Repo.update(changeset) do
      {:ok, custom_field} ->
        conn
        |> put_flash(:info, "Custom field #{custom_field.name} saved")
        |> redirect(to: project_offer_custom_field_path(conn, :add, project_id, offer_id))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Oops! Make sure you entered a value")
        |> redirect(to: project_offer_custom_field_path(conn, :add, project_id, offer_id))
    end
  end


  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end
end
