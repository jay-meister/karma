defmodule Karma.StartpackController do
  use Karma.Web, :controller

  alias Karma.Startpack
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

  def index(conn, _params) do
    startpacks = Repo.all(Startpack)
    render(conn, "index.html", startpacks: startpacks)
  end

  def show(conn, %{"id" => id}) do
    startpack = Repo.get!(Startpack, id)
    render(conn, "show.html", startpack: startpack)
  end

  def edit(conn, %{"id" => id}) do
    startpack = Repo.get!(Startpack, id)
    changeset = Startpack.changeset(startpack)
    render(conn, "edit.html", startpack: startpack, changeset: changeset)
  end

  def update(conn, %{"id" => id, "startpack" => startpack_params}) do
    # should validate before uploading?
    startpack = Repo.get!(Startpack, id)

    urls = Karma.S3.upload_many(startpack_params, @file_upload_keys)

    params = Map.merge(startpack_params, urls)

    changeset = Startpack.changeset(startpack, params)

    case Repo.update(changeset) do
      {:ok, startpack} ->
        conn
        |> put_flash(:info, "Startpack updated successfully.")
        |> redirect(to: startpack_path(conn, :show, startpack))
      {:error, changeset} ->
        render(conn, "edit.html", startpack: startpack, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    startpack = Repo.get!(Startpack, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(startpack)

    conn
    |> put_flash(:info, "Startpack deleted successfully.")
    |> redirect(to: startpack_path(conn, :index))
  end
end
