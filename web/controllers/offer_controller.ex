defmodule Karma.OfferController do
  use Karma.Web, :controller

  alias Karma.Offer

  def index(conn, %{"project_id" => project_id}) do
    IO.puts "--------- inside offers index ----------"
    offers = Repo.all(Offer)
    IO.inspect offers
    # we should know project id here, placeholder to 1
    render(conn, "index.html", offers: offers, project_id: 1)
  end

  def new(conn, %{"project_id" => project_id}) do
    changeset = Offer.changeset(%Offer{})
    # we should know project id here, placeholder to 1
    IO.inspect changeset
    render(conn, "new.html", changeset: changeset, project_id: 1)
  end

  def create(conn, %{"offer" => offer_params} = params) do
    changeset = Offer.changeset(%Offer{}, offer_params)
    IO.inspect changeset
    case Repo.insert(changeset) do
      {:ok, offer} ->
        conn
        |> put_flash(:info, "Offer created successfully.")
        |> redirect(to: project_offer_path(conn, :index, 1))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"project_id" => project_id, "id" => id}) do
    offer = Repo.get!(Offer, id)
    render(conn, "show.html", offer: offer)
  end

  def edit(conn, %{"project_id" => project_id, "id" => id}) do
    offer = Repo.get!(Offer, id)
    changeset = Offer.changeset(offer)
    render(conn, "edit.html", offer: offer, changeset: changeset)
  end

  def update(conn, %{"id" => id, "offer" => offer_params}) do
    offer = Repo.get!(Offer, id)
    changeset = Offer.changeset(offer, offer_params)

    case Repo.update(changeset) do
      {:ok, offer} ->
        conn
        |> put_flash(:info, "Offer updated successfully.")
        |> redirect(to: project_offer_path(conn, :show, offer.project_id, offer))
      {:error, changeset} ->
        render(conn, "edit.html", offer: offer, changeset: changeset)
    end
  end

  def delete(conn, %{"project_id" => project_id, "id" => id}) do
    offer = Repo.get!(Offer, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(offer)

    conn
    |> put_flash(:info, "Offer deleted successfully.")
    |> redirect(to: project_offer_path(conn, :index, offer.project_id))
  end
end
