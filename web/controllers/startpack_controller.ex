defmodule Karma.StartpackController do
  use Karma.Web, :controller

  alias Karma.{Startpack, Offer, Controllers.Helpers}
  # possible solution for multiple fields
   @file_upload_keys [
     {"passport_image", "passport_url"},
     {"vehicle_insurance_image", "vehicle_insurance_url"},
     {"box_rental_image", "box_rental_url"},
     {"equipment_rental_image", "equipment_rental_url"},
     {"p45_image", "p45_url"},
     {"schedule_d_letter_image", "schedule_d_letter_url"},
     {"loan_out_company_cert_image", "loan_out_company_cert_url"}
   ]

  def index(conn, _params, user) do
    startpack = Repo.one(Helpers.user_startpack(user))
    changeset = Startpack.changeset(%Startpack{}, Map.from_struct(startpack))
    case Map.has_key?(conn.query_params, "offer_id") do
      true ->
        offer_id = String.to_integer(conn.query_params["offer_id"])
        case Repo.get_by(Offer, id: offer_id) do
          nil ->
            render(conn, "index.html", startpack: startpack, changeset: changeset, offer: %{}, user: user)
          offer ->
            mother_changeset = Startpack.mother_changeset(%Startpack{}, Map.from_struct(startpack), offer)
            mother_changeset = %{mother_changeset | action: :insert}
            render(conn, "index.html", startpack: startpack, changeset: mother_changeset, offer: offer, user: user)
        end
      false ->
        render(conn, "index.html", startpack: startpack, changeset: changeset, offer: %{}, user: user)
      end
  end

  def update(conn, %{"id" => id, "startpack" => startpack_params}, user) do
    startpack = Repo.get!(Startpack, id)

    image_changeset = Startpack.upload_type_validation(%Startpack{}, startpack_params)
    case image_changeset.valid? do
      false ->
        conn
        |> put_flash(:error, "Error updating startpack!")
        |> render("index.html", changeset: image_changeset, startpack: startpack, offer: %{}, user: user)
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

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end
end
