defmodule Karma.OfferController do
  use Karma.Web, :controller

  alias Karma.{User, Offer, Project, LayoutView}

  import Karma.ProjectController, only: [project_owner: 2]
  plug :project_owner when action in [:index, :new, :create, :show, :edit, :update, :delete]

  plug :offer_pending when action in [:edit, :update, :delete]

  # Function plug that checks if offer is pending or not
  # halts any other action if offer is not pending
  def offer_pending(conn, _) do
    %{"id" => id, "project_id" => project_id} = conn.params
    case Repo.get(Offer, id) do
      %Offer{accepted: nil} ->
        conn
      %Offer{} ->
        conn
        |> put_flash(:error, "You can only edit pending offers")
        |> redirect(to: project_offer_path(conn, :index, project_id))
        |> halt()
    end
  end


  def index(conn, %{"project_id" => project_id}) do
    project = Repo.get!(Project, project_id)
    offers =
      Offer
      |> Offer.projects_offers(project)
      |> Repo.all()

    render conn, "index.html", layout: {LayoutView, "no_container.html"}, offers: offers, project: project
  end

  def new(conn, %{"project_id" => project_id}) do
    changeset = Offer.changeset(%Offer{})
    job_titles = Karma.Job.titles()
    job_departments = Karma.Job.departments()
    render(conn, "new.html", changeset: changeset, project_id: project_id, job_titles: job_titles, job_departments: job_departments)
  end

  def create(conn, %{"offer" => offer_params, "project_id" => project_id}) do
    project = Repo.get(Project, project_id)

    %{"target_email" => user_email,
    "fee_per_day_inc_holiday" => fee_per_day_inc_holiday,
    "working_week" => working_week,
    "department" => department,
    "job_title" => job_title,
    "sixth_day_fee_multiplier" => sixth_day_fee_multiplier,
    "seventh_day_fee_multiplier" => seventh_day_fee_multiplier} = offer_params

    sixth_day_fee_multiplier = String.to_float(sixth_day_fee_multiplier)
    seventh_day_fee_multiplier = String.to_float(seventh_day_fee_multiplier)

    working_week =
      case working_week do
        "" -> ""
        _ww -> String.to_float(working_week)
      end
    fee_per_day_inc_holiday =
      case fee_per_day_inc_holiday do
         "" -> ""
         _fpdih -> String.to_integer(fee_per_day_inc_holiday)
      end

    fee_per_day_exc_holiday = calc_fee_per_day_exc_holiday(fee_per_day_inc_holiday, project.holiday_rate)
    holiday_pay_per_day = calc_holiday_pay_per_day(fee_per_day_inc_holiday, fee_per_day_exc_holiday)
    fee_per_week_inc_holiday = calc_fee_per_week_inc_holiday(fee_per_day_inc_holiday, working_week)
    fee_per_week_exc_holiday = calc_fee_per_week_exc_holiday(fee_per_week_inc_holiday, project.holiday_rate)
    holiday_pay_per_week = calc_holiday_pay_per_week(fee_per_week_inc_holiday, fee_per_week_exc_holiday)
    contract_type = determine_contract_type(department, job_title)
    sixth_day_fee_inc_holiday = calc_day_fee_inc_holidays(fee_per_day_inc_holiday, sixth_day_fee_multiplier)
    sixth_day_fee_exc_holiday = calc_day_fee_exc_holidays(fee_per_day_exc_holiday, sixth_day_fee_multiplier)
    seventh_day_fee_inc_holiday = calc_day_fee_inc_holidays(fee_per_day_inc_holiday, seventh_day_fee_multiplier)
    seventh_day_fee_exc_holiday = calc_day_fee_exc_holidays(fee_per_day_exc_holiday, seventh_day_fee_multiplier)

    offer_params = Map.put(offer_params, "fee_per_day_exc_holiday", fee_per_day_exc_holiday)
    offer_params = Map.put(offer_params, "sixth_day_fee_multiplier", sixth_day_fee_multiplier)
    offer_params = Map.put(offer_params, "seventh_day_fee_multiplier", seventh_day_fee_multiplier)
    offer_params = Map.put(offer_params, "holiday_pay_per_day", holiday_pay_per_day)
    offer_params = Map.put(offer_params, "fee_per_week_inc_holiday", fee_per_week_inc_holiday)
    offer_params = Map.put(offer_params, "fee_per_week_exc_holiday", fee_per_week_exc_holiday)
    offer_params = Map.put(offer_params, "holiday_pay_per_week", holiday_pay_per_week)
    offer_params = Map.put_new(offer_params, "contract_type", contract_type)
    offer_params = Map.put_new(offer_params, "sixth_day_fee_inc_holiday", sixth_day_fee_inc_holiday)
    offer_params = Map.put_new(offer_params, "sixth_day_fee_exc_holiday", sixth_day_fee_exc_holiday)
    offer_params = Map.put_new(offer_params, "seventh_day_fee_inc_holiday", seventh_day_fee_inc_holiday)
    offer_params = Map.put_new(offer_params, "seventh_day_fee_exc_holiday", seventh_day_fee_exc_holiday)

    user = Repo.get_by(User, email: user_email)

    changeset = case user do
      nil -> # user is not yet registered or target_email is empty
        project
        |> build_assoc(:offers)
        |> Offer.changeset(offer_params)
      user -> # user is already registered
        project
        |> build_assoc(:offers)
        |> Offer.changeset(offer_params)
        |> Ecto.Changeset.put_assoc(:user, user)
    end

    case Repo.insert(changeset) do
      {:ok, offer} ->
        # email function decides whether this is a registered user
        Karma.Email.send_new_offer_email(conn, offer)
        |> Karma.Mailer.deliver_later()
        conn
        |> put_flash(:info, "Offer sent to #{offer.target_email}")
        |> redirect(to: project_offer_path(conn, :index, project_id))
      {:error, changeset} ->
        job_titles = Karma.Job.titles()
        job_departments = Karma.Job.departments()
        render(conn, "new.html", changeset: changeset, project_id: project_id, job_titles: job_titles, job_departments: job_departments)
    end
  end

  def show(conn, %{"project_id" => project_id, "id" => id}) do
    offer = Repo.get!(Offer, id)
    render(conn, "show.html", offer: offer, project_id: project_id)
  end

  def edit(conn, %{"project_id" => project_id, "id" => id}) do
    offer = Repo.get!(Offer, id)
    changeset = Offer.changeset(offer)
    job_titles = Karma.Job.titles()
    job_departments = Karma.Job.departments()
    render(conn, "edit.html", offer: offer, changeset: changeset, project_id: project_id, job_titles: job_titles, job_departments: job_departments)
  end


  def update(conn, %{"project_id" => project_id, "id" => id, "offer" => offer_params}) do
    offer = Repo.get!(Offer, id)
    changeset = Offer.changeset(offer, offer_params)

    case Repo.update(changeset) do
      {:ok, offer} ->
        # email function decides whether this is a registered user
        Karma.Email.send_updated_offer_email(conn, offer)
        |> Karma.Mailer.deliver_later()

        conn
        |> put_flash(:info, "Offer updated successfully.")
        |> redirect(to: project_offer_path(conn, :show, offer.project_id, offer))
      {:error, changeset} ->
        job_titles = Karma.Job.titles()
        job_departments = Karma.Job.departments()
        render(conn, "edit.html", offer: offer, changeset: changeset, project_id: project_id, job_titles: job_titles, job_departments: job_departments)
    end
  end

  def delete(conn, %{"id" => id}) do
    offer = Repo.get!(Offer, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(offer)

    conn
    |> put_flash(:info, "Offer deleted successfully.")
    |> redirect(to: project_offer_path(conn, :index, offer.project_id))
  end
end
