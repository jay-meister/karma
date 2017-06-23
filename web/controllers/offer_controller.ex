defmodule Karma.OfferController do
  use Karma.Web, :controller

  alias Karma.{User, Offer, Project, Startpack, AlteredDocument, Merger}

  import Karma.ProjectController, only: [add_project_to_conn: 2, block_if_not_project_manager: 2]

  # add project to conn
  plug :add_project_to_conn when action in [:index, :new, :create, :show, :edit, :update, :delete, :response]

  # block access if current user is not PM of this project
  plug :block_if_not_project_manager when action in [:index, :new, :create, :edit, :update, :delete]

  # add offer to conn
  plug :add_offer_to_conn when action in [:show, :edit, :update, :delete, :response]

  # block access if not contractor
  plug :block_if_not_contractor when action in [:response]

  # block access if current user does not own the current offer
  plug :block_if_not_contractor_or_pm when action in [:show, :response]

  # block update and delete functionality when offer is not pending
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

  def add_offer_to_conn(conn, _) do
    %{"id" => offer_id} = conn.params
    # offer
    offer = Repo.get_by(Offer, id: offer_id)
    conn = assign(conn, :offer, offer)
    case conn.assigns.offer do
      nil ->
        conn
        |> put_flash(:error, "Offer could not be found")
        |> render(Karma.ErrorView, "404.html")
        |> halt()
      _ ->
        # assign is_contractor?
        is_contractor? = conn.assigns.current_user.id == conn.assigns.offer.user_id
        assign(conn, :is_contractor?, is_contractor?)
      end
  end

  def block_if_not_contractor_or_pm(conn, _) do
    # block if user is not contractor
    case conn.assigns do
      %{is_pm?: false, is_contractor?: false} ->
        conn
        |> put_flash(:error, "You do not have permission to view that offer")
        |> redirect(to: dashboard_path(conn, :index))
        |> halt()
      _ ->
        conn
    end
  end

  def block_if_not_contractor(conn, _) do
    case conn.assigns do
      %{is_contractor?: false} ->
        conn
        |> put_flash(:error, "You do not have permission to respond to that offer")
        |> redirect(to: dashboard_path(conn, :index))
        |> halt()
      _ ->
        conn
    end
  end

  def index(conn, %{"project_id" => project_id}) do
    project =
      Repo.get!(Project, project_id)
      |> Repo.preload(:offers)
    offers =
      Offer
      |> Offer.projects_offers(project)
      |> Repo.all()

    ops = [offers: offers, project: project]
    render conn, "index.html", ops
  end

  def new(conn, %{"project_id" => project_id}) do
    changeset = Offer.changeset(%Offer{})
    job_titles = Karma.Job.titles()
    job_departments = Karma.Job.departments()
    render(conn,
    "new.html",
    changeset: changeset,
    project_id: project_id,
    job_titles: job_titles,
    job_departments: job_departments,
    job_title: "")
  end

  def create(conn, %{"offer" => offer_params, "project_id" => project_id}) do
    project = Repo.get(Project, project_id) |> Repo.preload(:user)
    %{"department" => department, "job_title" => job_title} = offer_params
    contract_type = determine_contract_type(department, job_title)
    offer_params = Map.put(offer_params, "contract_type", contract_type)
    # first check the values provided by the user are valid
    validation_changeset = Offer.form_validation(%Offer{}, offer_params)

    # if not valid, return to user with errors
    if !validation_changeset.valid? do
      changeset = %{validation_changeset | action: :insert} # manually set the action so errors are shown
      job_titles = Karma.Job.titles()
      job_departments = Karma.Job.departments()
      job_title = Map.get(changeset.changes, :job_title, "")

      render(conn,
      "new.html",
      changeset: changeset,
      project_id: project_id,
      job_titles: job_titles,
      job_departments: job_departments,
      job_title: job_title)
    else
      # run calculations and add them to the offer_params
      calculations = parse_offer_strings(offer_params) |> run_calculations(project)
      offer_params = Map.merge(offer_params, calculations)

      changeset = changeset_maybe_with_user(offer_params, project)

      case Repo.insert(changeset) do
        {:ok, offer} ->
          # email function decides whether this is a registered user
          Karma.Email.send_new_offer_email(conn, offer, project)
          |> Karma.Mailer.deliver_later()
          conn
          |> put_flash(:info, "Offer sent to #{offer.target_email}")
          |> redirect(to: project_offer_path(conn, :index, project_id))
        {:error, changeset} ->
          job_titles = Karma.Job.titles()
          job_departments = Karma.Job.departments()
          job_title = Map.get(changeset.changes, :job_title, "")

          render(conn, "new.html", changeset: changeset, project_id: project_id, job_titles: job_titles, job_departments: job_departments, job_title: job_title)
      end
    end
  end

  def show(conn, %{"project_id" => project_id, "id" => id}) do
    offer = conn.assigns.offer
    user = conn.assigns.current_user
    query = from a in AlteredDocument, where: a.offer_id == ^id
    offer_related_documents = Repo.all(query) |> Repo.preload(:document)
    # todo fix this one
    case offer.user_id do
      nil ->
        changeset = Startpack.changeset(%Startpack{})
        render(conn, "show.html", project_id: project_id, changeset: changeset, contract: nil)
      _ ->
        edit_changeset = Offer.changeset(offer)
        startpack = Repo.get_by(Startpack, user_id: user.id)
        startpack =  Map.from_struct(startpack)
        changeset = Startpack.mother_changeset(%Startpack{}, startpack, offer)
        render(conn,
        "show.html",
        project_id: project_id,
        changeset: changeset,
        edit_changeset: edit_changeset,
        documents: offer_related_documents
        )
    end
  end

  def edit(conn, %{"project_id" => project_id, "id" => id}) do
    offer = Repo.get!(Offer, id)
    changeset = Offer.changeset(offer)
    job_titles = Karma.Job.titles()
    job_departments = Karma.Job.departments()

    ops = [offer: offer, changeset: changeset, project_id: project_id, job_titles: job_titles, job_departments: job_departments]
    render(conn, "edit.html", ops)
  end


  def update(conn, %{"project_id" => project_id, "id" => id, "offer" => offer_params}) do

    offer =
      Repo.get!(Offer, id)
      |> Repo.preload(:user)
      |> Repo.preload(:project)

    project = Repo.get(Project, project_id) |> Repo.preload(:user)
    job_titles = Karma.Job.titles()
    job_departments = Karma.Job.departments()
    ops = [
      offer: offer,
      project_id: project_id,
      job_titles: job_titles,
      job_departments: job_departments,
      job_title: offer.job_title
    ]
    # first check the values provided by the user are valid
    validation_changeset = Offer.form_validation(offer, offer_params)
    # if not valid, return to user with errors
    if !validation_changeset.valid? do
      changeset = %{validation_changeset | action: :insert} # manually set the action so errors are shown
      render(conn, "edit.html", ops ++ [changeset: changeset])
    else
      case validation_changeset.changes == %{} do
        true ->
          conn
          |> put_flash(:error, "Nothing to update")
          |> render("edit.html", ops ++ [changeset: validation_changeset])
        false ->
          # run calculations and add them to the offer_params
          calculations = parse_offer_strings(offer_params) |> run_calculations(project)
          offer_params = Map.merge(offer_params, calculations)
          %{"department" => department, "job_title" => job_title} = offer_params
          contract_type = determine_contract_type(department, job_title)
          offer_params = Map.put(offer_params, "contract_type", contract_type)
          changeset = Offer.changeset(offer, offer_params)

          {:ok, offer} = Repo.update(changeset)
          # email function decides whether this is a registered user
          Karma.Email.send_updated_offer_email(conn, offer, project)
          |> Karma.Mailer.deliver_later()

          conn
          |> put_flash(:info, "Offer updated successfully, and re-emailed to recipient.")
          |> redirect(to: project_offer_path(conn, :show, offer.project_id, offer))
      end
    end
  end

  def response(conn, %{"project_id" => project_id, "id" => id, "offer" => offer_params}) do
    offer =
      Repo.get!(Offer, id)
      |> Repo.preload(:user)
      |> Repo.preload(:project)

    project = Repo.get(Project, project_id) |> Repo.preload(:user)
    changeset = Offer.offer_response_changeset(offer, offer_params)

    # get the relevant original forms for merging
    form_query = Karma.Controllers.Helpers.get_forms_for_merging(offer)
    documents = Repo.all(form_query)

    # check if there is a document to be merged
    case length(documents) > 0 do
      false -> # prevent accepting offer if no document
        conn
        |> put_flash(:error, "There were no documents to merge your data with")
        |> redirect(to: project_offer_path(conn, :show, offer.project_id, offer))
      true ->
        case Repo.update(changeset) do
          {:error, _changeset} ->
            conn
            |> put_flash(:error, "Error making response!")
            |> redirect(to: project_offer_path(conn, :show, offer.project_id, offer))
          {:ok, offer} ->
            Karma.Email.send_offer_response_pm(conn, offer, project)
            |> Karma.Mailer.deliver_later()

            case offer.accepted do
              false ->
                conn
                |> put_flash(:info, "Offer rejected!")
                |> redirect(to: project_offer_path(conn, :show, offer.project_id, offer))
              true ->
                Karma.Email.send_offer_accepted_contractor(conn, offer)
                |> Karma.Mailer.deliver_later()

                # now merge data
                case Merger.merge_multiple(offer, documents) do
                  {:error, msg} ->
                    # Un-accept the offer so they can accept again when changes have been made
                    Repo.update(Ecto.Changeset.change(offer, %{accepted: nil}))

                    conn
                    |> put_flash(:error, msg)
                    |> redirect(to: project_offer_path(conn, :show, offer.project_id, offer))
                  {:ok, msg} ->
                    # reply to user
                    conn
                    |> put_flash(:info, "#{msg}")
                    |> redirect(to: project_offer_path(conn, :show, offer.project_id, offer))
                end
            end
        end
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


  # changeset helper for create function
  def changeset_maybe_with_user(params, project) do
    %{"target_email" => user_email} = params
    user = Repo.get_by(User, email: user_email)

    case user do
      nil -> # user is not yet registered or target_email is empty
        project
        |> build_assoc(:offers)
        |> Offer.changeset(params)
      user -> # user is already registered
        project
        |> build_assoc(:offers)
        |> Offer.changeset(params)
        |> Ecto.Changeset.put_assoc(:user, user)
    end
  end

  # calculations helpers
  def parse_offer_strings(offer_params) do
    integers = ["fee_per_day_inc_holiday"]
    floats = ["working_week", "sixth_day_fee_multiplier", "seventh_day_fee_multiplier"]

    offer_params
    |> update_keys(integers, &String.to_integer/1)
    |> update_keys(floats, &String.to_float/1)
  end

  defp update_keys(params, keys, f) do
    # map over the keys of params, applying function f to each of the keys given
    Enum.reduce(keys, params, fn(i, acc) -> Map.update!(acc, i, f) end)
  end

  def run_calculations(params, project) do
    %{"fee_per_day_inc_holiday" => fee_per_day_inc_holiday,
    "working_week" => working_week,
    "job_title" => job_title,
    "department" => department,
    "sixth_day_fee_multiplier" => sixth_day_fee_multiplier,
    "seventh_day_fee_multiplier" => seventh_day_fee_multiplier
    } = params

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

    %{
    "fee_per_day_exc_holiday" => fee_per_day_exc_holiday,
    "holiday_pay_per_day" => holiday_pay_per_day,
    "fee_per_week_inc_holiday" => fee_per_week_inc_holiday,
    "fee_per_week_exc_holiday" => fee_per_week_exc_holiday,
    "holiday_pay_per_week" => holiday_pay_per_week,
    "contract_type" => contract_type,
    "sixth_day_fee_inc_holiday" => sixth_day_fee_inc_holiday,
    "sixth_day_fee_exc_holiday" => sixth_day_fee_exc_holiday,
    "seventh_day_fee_inc_holiday" => seventh_day_fee_inc_holiday,
    "seventh_day_fee_exc_holiday" => seventh_day_fee_exc_holiday
    }
  end
end
