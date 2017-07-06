defmodule Karma.StartpackController do
  use Karma.Web, :controller

  alias Karma.{Startpack, Offer, Controllers.Helpers}
  # possible solution for multiple fields
   @file_upload_keys [
     {"passport_image", "passport_url"},
     {"vehicle_insurance_image", "vehicle_insurance_url"},
     {"vehicle_license_image", "vehicle_license_url"},
     {"box_rental_image", "box_rental_url"},
     {"equipment_rental_image", "equipment_rental_url"},
     {"p45_image", "p45_url"},
     {"schedule_d_letter_image", "schedule_d_letter_url"},
     {"loan_out_company_cert_image", "loan_out_company_cert_url"}
   ]

  def index(conn, _params, user) do
    startpack = Repo.one(Helpers.user_startpack(user))
    startpack_map = Map.from_struct(startpack)
    uploaded_files = get_uploaded_files(startpack_map)
    changeset = Startpack.changeset(%Startpack{}, startpack_map)
    delete_changeset = Startpack.delete_changeset(%Startpack{}, startpack_map)
    case Map.has_key?(conn.query_params, "offer_id") do
      true ->
        offer_id = String.to_integer(conn.query_params["offer_id"])
        case Repo.get_by(Offer, id: offer_id) do
          nil ->
            render(conn, "index.html", startpack: startpack, changeset: changeset, offer: %{}, user: user, delete_changeset: delete_changeset, uploaded_files: uploaded_files)
          offer ->
            mother_changeset = Startpack.mother_changeset(%Startpack{}, Map.from_struct(startpack), offer)
            mother_changeset = %{mother_changeset | action: :insert}
            render(conn, "index.html", startpack: startpack, changeset: mother_changeset, offer: offer, user: user, delete_changeset: delete_changeset, uploaded_files: uploaded_files)
        end
      false ->
        render(conn, "index.html", startpack: startpack, changeset: changeset, offer: %{}, user: user, delete_changeset: delete_changeset, uploaded_files: uploaded_files)
      end
  end

  def update(conn, %{"id" => id, "startpack" => startpack_params}, user) do
    startpack = Repo.get!(Startpack, id)
    startpack_map = Map.from_struct(startpack)
    uploaded_files = get_uploaded_files(startpack_map)
    delete_changeset = Startpack.delete_changeset(%Startpack{}, startpack_map)
    image_changeset = Startpack.upload_type_validation(%Startpack{}, startpack_params)
    case image_changeset.valid? do
      false ->
        conn
        |> put_flash(:error, "Error updating startpack!")
        |> render("index.html", changeset: image_changeset, startpack: startpack, offer: %{}, user: user, delete_changeset: delete_changeset, uploaded_files: uploaded_files)
      true ->
        urls = Karma.S3.upload_many(startpack_params, @file_upload_keys)

        params = Map.merge(startpack_params, urls)

        changeset = Startpack.changeset(startpack, params)

        offer_id = Map.get(conn.query_params, "offer_id", "")

        _startpack = Repo.update!(changeset)
        case offer_id == "" do
          true ->
            conn
            |> put_flash(:info, "Startpack updated successfully!")
            |> redirect(to: startpack_path(conn, :index))
          false ->
            conn
            |> put_flash(:info, "Startpack updated successfully!")
            |> redirect(to: startpack_path(conn, :index, offer_id: offer_id))
        end
    end
  end

  def delete_uploaded_files(conn, %{"id" => startpack_id, "startpack" => startpack_params}, _user) do
    startpack = Repo.get(Startpack, startpack_id)
    changeset = Startpack.delete_changeset(startpack, startpack_params)
    Repo.update!(changeset)
    conn
    |> put_flash(:info, "File deleted successfully!")
    |> redirect(to: startpack_path(conn, :index))
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

  defp convert_atom_to_name(atom) do
    atom
    |> Atom.to_string()
    |> String.replace("_url", "")
    |> String.replace("_", " ")
    |> String.replace("license", "licence")
    |> String.upcase()
  end

  defp get_uploaded_files(startpack_map) do
    upload_map = Map.take(startpack_map, [
      :loan_out_company_cert_url,
      :schedule_d_letter_url,
      :p45_url,
      :equipment_rental_url,
      :box_rental_url,
      :vehicle_license_url,
      :vehicle_insurance_url,
      :passport_url
      ])
    upload_atoms = Map.keys(upload_map)
    upload_values = Map.values(upload_map)
    upload_names = Enum.map(upload_atoms, fn atom -> convert_atom_to_name(atom) end)
    atom_keyword_list = for atom <- upload_atoms do
      %{atom: atom}
    end
    value_keyword_list = for value <- upload_values do
      %{value: value}
    end
    name_keyword_list = for name <- upload_names do
      %{name: name}
    end
    zipped_list = Enum.zip([name_keyword_list, atom_keyword_list, value_keyword_list])
    Enum.map(zipped_list, fn {name_map, atom_map, value_map} -> %{name: name_map.name, atom: atom_map.atom, value: value_map.value} end)
    |> Enum.filter(fn map -> map.value != nil end)
    |> Enum.filter(fn map -> map.value != "" end)
  end
end
