defmodule Engine.CustomFieldController do
  use Engine.Web, :controller
  alias Engine.{CustomField, Offer}
  import Engine.ProjectController, only: [add_project_to_conn: 2, block_if_not_project_manager: 2]


  plug :authenticate when action in [:create, :delete, :add, :save, :revise]

  plug :add_project_to_conn when action in [:create, :delete, :add, :save, :revise]

  plug :block_if_not_project_manager when action in [:add, :save, :create, :revise, :delete]


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
    all_offer_fields =
      project.custom_fields
      |> Enum.filter(fn field -> field.type == "Offer" end)

    custom_project_offer_fields =
      all_offer_fields
      |> Enum.filter(fn field -> field.value == nil end)

    custom_offer_specific_fields =
      all_offer_fields
      |> Enum.filter(fn field -> field.offer_id == String.to_integer(offer_id) end)
      |> Enum.sort(&(&1.name <= &2.name))

    custom_project_offer_count =
      custom_project_offer_fields
      |> Enum.count()

    custom_offer_field_count =
      custom_offer_specific_fields
      |> Enum.count()


    empty_fields = custom_project_offer_count - custom_offer_field_count

    custom_offer_field_names = Enum.map(custom_offer_specific_fields, fn field -> field.name end)

    filtered_list =
      custom_project_offer_fields
      |> Enum.filter(fn(e) -> !Enum.member?(custom_offer_field_names, e.name) end)
      |> Enum.sort(&(&1.name <= &2.name))

    offer_changeset = Offer.send_offer_changeset(%Offer{})

    render conn, "add.html",
    changeset: changeset,
    custom_project_offer_fields: custom_project_offer_fields,
    project_id: project_id,
    offer_id: offer_id,
    empty_fields: empty_fields,
    offer_changeset: offer_changeset,
    filtered_list: filtered_list,
    custom_offer_specific_fields: custom_offer_specific_fields,
    offer_id: offer_id
  end

  def save(conn, %{"project_id" => project_id, "offer_id" => offer_id, "custom_field" => custom_field_params}, user) do
    project = Repo.get(user_projects(user), project_id)
    offer = Repo.get(Offer, offer_id)
    new =
      custom_field_params
      |> Map.put_new("type", "Offer")

    changeset =
      project
      |> build_assoc(:custom_fields)
      |> CustomField.value_changeset(new)
      |> Ecto.Changeset.put_assoc(:offer, offer)

    case Repo.insert(changeset) do
      {:ok, custom_field} ->
        conn
        |> put_flash(:info, "Custom field #{custom_field.name} saved")
        |> redirect(to: project_offer_custom_field_path(conn, :add, project_id, offer_id))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Oops! Make sure you entered a value")
        |> redirect(to: project_offer_custom_field_path(conn, :add, project_id, offer_id))
    end
  end

  def revise(conn, %{"project_id" => project_id, "offer_id" => offer_id, "id" => id, "custom_field" => custom_field_params}, _user) do
    custom_field = Repo.get!(CustomField, id)
    changeset = CustomField.value_changeset(custom_field, custom_field_params)

    case Repo.update(changeset) do
      {:ok, custom_field} ->
        conn
        |> put_flash(:info, "Custom field #{custom_field.name} updated")
        |> redirect(to: project_offer_custom_field_path(conn, :add, project_id, offer_id))
      {:error, _changeset} ->
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
