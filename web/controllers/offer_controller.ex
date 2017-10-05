defmodule Engine.OfferController do
  use Engine.Web, :controller

  alias Engine.{User, Offer, Project, Startpack, AlteredDocument, Merger, Formatter}

  import Engine.ProjectController, only: [add_project_to_conn: 2, block_if_not_project_manager: 2]

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
        |> render(Engine.ErrorView, "404.html")
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
      |> Repo.preload(:user)
      |> Enum.sort(&(&1.updated_at >= &2.updated_at))

    ops = [offers: offers, project: project]
    render conn, "index.html", ops
  end

  def new(conn, %{"project_id" => project_id}) do
    changeset = Offer.changeset(%Offer{})
    job_titles = Engine.Job.titles()
    job_departments = Engine.Job.departments()
    project = Repo.get(Project, project_id) |> Repo.preload(:custom_fields)
    num_custom_offer_fields =
      project.custom_fields
      |> Enum.filter(fn field -> field.type == "Offer" end)
      |> Enum.count()

    render(conn,
    "new.html",
    changeset: changeset,
    project_id: project_id,
    job_titles: job_titles,
    job_departments: job_departments,
    job_title: "",
    full_name: "",
    num_custom_offer_fields: num_custom_offer_fields)
  end

  def create(conn, %{"offer" => %{"target_email" => email} = offer_params, "project_id" => project_id}) do
    offer_params = Map.put(offer_params, "target_email", String.downcase(email))
    %{"recipient_fullname" => recipient_fullname} = offer_params
    project = Repo.get(Project, project_id) |> Repo.preload(:user) |> Repo.preload(:documents) |> Repo.preload(:custom_fields)
    project_documents = Enum.map(project.documents, fn document -> document.name end)
    project_custom_fields = project.custom_fields
    project_custom_offer_fields =
      project_custom_fields
      |> Enum.filter(fn field -> field.type == "Offer" end)
    num_custom_offer_fields =
      project.custom_fields
      |> Enum.filter(fn field -> field.type == "Offer" end)
      |> Enum.count()
    %{"department" => department,
    "job_title" => job_title,
    "daily_or_weekly" => daily_or_weekly,
    "equipment_rental_required?" => equipment_rental_required?} = offer_params
    equipment = equipment_rental_required? == "true"
    daily = daily_or_weekly == "daily"
    contract_type = determine_contract_type(department, job_title, project_documents, daily, equipment)
    offer_params = Map.put(offer_params, "contract_type", contract_type)
    # first check the values provided by the user are valid
    validation_changeset = Offer.form_validation(%Offer{}, offer_params)
    # if not valid, return to user with errors
    if !validation_changeset.valid? do
      changeset = %{validation_changeset | action: :insert} # manually set the action so errors are shown
      job_titles = Engine.Job.titles()
      job_departments = Engine.Job.departments()
      job_title = Map.get(changeset.changes, :job_title, "")

      render(conn,
      "new.html",
      changeset: changeset,
      project_id: project_id,
      job_titles: job_titles,
      job_departments: job_departments,
      job_title: job_title,
      full_name: recipient_fullname, num_custom_offer_fields: num_custom_offer_fields)
    else
      # run calculations and add them to the offer_params
      calculations = parse_offer_strings(offer_params) |> run_calculations(project, project_documents, daily, equipment)
      offer_params = Map.merge(offer_params, calculations)
      changeset = changeset_maybe_with_user(offer_params, project)

      case Repo.insert(changeset) do
        {:ok, offer} ->
          case length(project_custom_offer_fields) == 0 do
            false ->
              conn
              |> put_flash(:info, "Offer created, now complete your custom fields")
              |> redirect(to: project_offer_custom_field_path(conn, :add, project_id, offer.id))
            true ->
              # email function decides whether this is a registered user
              Engine.Email.send_new_offer_email(conn, offer, project)
              |> Engine.Mailer.deliver_later()
              conn
              |> put_flash(:info, "Offer sent to #{offer.target_email}")
              |> redirect(to: project_offer_path(conn, :index, project_id))
          end
        {:error, changeset} ->
          job_titles = Engine.Job.titles()
          job_departments = Engine.Job.departments()
          job_title = Map.get(changeset.changes, :job_title, "")
          render(conn, "new.html", changeset: changeset, project_id: project_id, job_titles: job_titles, job_departments: job_departments, job_title: job_title, num_custom_offer_fields: num_custom_offer_fields)
      end
    end
  end

  def send_offer(conn, %{"project_id" => project_id, "offer_id" => offer_id} = params) do
    IO.inspect params
    project = Repo.get!(Project, project_id)
    offer = Repo.get!(Offer, offer_id)
    # email function decides whether this is a registered user
    Engine.Email.send_new_offer_email(conn, offer, project)
    |> Engine.Mailer.deliver_later()
    conn
    |> put_flash(:info, "Offer sent to #{offer.target_email}")
    |> redirect(to: project_offer_path(conn, :index, project_id))

  end

  def show(conn, %{"project_id" => project_id, "id" => id}) do
    offer = conn.assigns.offer
    contractor =
      case Repo.get_by(User, email: offer.target_email) |> Repo.preload(:startpacks) do
        nil -> %{}
        contractor -> contractor
      end
    supporting_documents =
      case offer.accepted do
        true ->
          [
            {"Passport image", contractor.startpacks.passport_url, true},
            {"Equipment rental list", contractor.startpacks.equipment_rental_url, offer.equipment_rental_required?},
            {"Box rental list", contractor.startpacks.box_rental_url, offer.box_rental_required?},
            {"Vehicle insurance image", contractor.startpacks.vehicle_insurance_url, offer.vehicle_allowance_per_week > 0},
            {"Schedule D letter", contractor.startpacks.schedule_d_letter_url, offer.contract_type == "SCHEDULE D"},
            {"Loan out company certificate", contractor.startpacks.loan_out_company_cert_url, contractor.startpacks.use_loan_out_company?},
            {"P45 image", contractor.startpacks.p45_url, offer.contract_type == "PAYE"},
          ]
        _not_true ->
          []
      end
    user = conn.assigns.current_user
    project = Repo.get(Project, project_id) |> Repo.preload(:documents) |> Repo.preload(:user) |> Repo.preload(:custom_fields)
    pm_email = project.user.email
    info_documents =
      Repo.all(project_documents(project))
      |> Enum.filter(fn doc -> doc.category == "Info" end)

    query = from a in AlteredDocument, where: a.offer_id == ^id
    merged_documents = Repo.all(query) |> Repo.preload(:document)
    deal_documents = Enum.filter(merged_documents, fn altered_doc -> altered_doc.document.category == "Deal" end)
    form_documents = Enum.filter(merged_documents, fn altered_doc -> altered_doc.document.category == "Form" end)

    custom_fields = Repo.all(project_custom_fields(project))
    custom_project_fields = Enum.filter(custom_fields, fn field -> field.type == "Project" end)
    custom_offer_fields =
      custom_fields
      |> Enum.filter(fn field -> field.type == "Offer" end)
      |> Enum.filter(fn field -> field.offer_id == String.to_integer(id) end)

    IO.inspect custom_offer_fields

    # todo fix this one
    case offer.user_id do
      nil ->
        changeset = Startpack.changeset(%Startpack{})
        render(conn,
        "show.html",
        project_id: project_id,
        changeset: changeset,
        contract: nil,
        contractor: contractor,
        formatted_offer: Formatter.format_offer_data(offer),
        supporting_documents: supporting_documents,
        pm_email: pm_email,
        custom_offer_fields: custom_offer_fields,
        custom_project_fields: custom_project_fields)
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
        info_documents: info_documents,
        deal_documents: deal_documents,
        form_documents: form_documents,
        contractor: contractor,
        formatted_offer: Formatter.format_offer_data(offer),
        supporting_documents: supporting_documents,
        pm_email: pm_email,
        custom_offer_fields: custom_offer_fields,
        custom_project_fields: custom_project_fields
        )
    end
  end

  def edit(conn, %{"project_id" => project_id, "id" => id}) do
    offer = Repo.get!(Offer, id)
    project = Repo.get(Project, project_id) |> Repo.preload(:custom_fields)
    num_custom_offer_fields =
      project.custom_fields
      |> Enum.filter(fn field -> field.type == "Offer" end)
      |> Enum.count()
    changeset = Offer.changeset(offer)
    job_titles = Engine.Job.titles()
    job_departments = Engine.Job.departments()
    full_name =
      case Repo.get_by(User, email: offer.target_email) do
        nil -> offer.recipient_fullname
        user -> "#{user.first_name} #{user.last_name}"
      end
    ops = [offer: offer, changeset: changeset, project_id: project_id, job_titles: job_titles, job_departments: job_departments, full_name: full_name, num_custom_offer_fields: num_custom_offer_fields]
    render(conn, "edit.html", ops)
  end


  def update(conn, %{"project_id" => project_id, "id" => id, "offer" => offer_params}) do

    offer =
      Repo.get!(Offer, id)
      |> Repo.preload(:user)
      |> Repo.preload(:project)

    project = Repo.get(Project, project_id) |> Repo.preload(:user) |> Repo.preload(:documents)
    project_documents = Enum.map(project.documents, fn document -> document.name end)
    daily = offer.daily_or_weekly == "daily"
    equipment = offer.equipment_rental_required?
    job_titles = Engine.Job.titles()
    job_departments = Engine.Job.departments()
    ops = [
      offer: offer,
      project_id: project_id,
      job_titles: job_titles,
      job_departments: job_departments,
      job_title: offer.job_title,
      full_name: offer.recipient_fullname
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
          calculations = parse_offer_strings(offer_params) |> run_calculations(project, project_documents, daily, equipment)
          offer_params = Map.merge(offer_params, calculations)
          %{"department" => department,
          "job_title" => job_title,
          "daily_or_weekly" => daily_or_weekly,
          "equipment_rental_required?" => equipment_rental_required?} = offer_params
          daily = daily_or_weekly == "daily"
          equipment = equipment_rental_required? == "true"
          contract_type = determine_contract_type(department, job_title, project_documents, daily, equipment)
          offer_params = Map.put(offer_params, "contract_type", contract_type)
          changeset = Offer.changeset(offer, offer_params)

          {:ok, offer} = Repo.update(changeset)
          # email function decides whether this is a registered user
          Engine.Email.send_updated_offer_email(conn, offer, project)
          |> Engine.Mailer.deliver_later()

          conn
          |> put_flash(:info, "Offer updated successfully, and re-emailed to recipient")
          |> redirect(to: project_offer_path(conn, :show, offer.project_id, offer))
      end
    end
  end

  def response(conn, %{"project_id" => project_id, "id" => id, "offer" => offer_params}) do
    offer =
      Repo.get!(Offer, id)
      |> Repo.preload(:user)
      |> Repo.preload(:project)

    project = Repo.get(Project, project_id) |> Repo.preload(:user) |> Repo.preload(:documents)
    project_documents = Enum.map(project.documents, fn document -> document.name end)

    changeset = Offer.offer_response_changeset(offer, offer_params)
    contractor = Repo.get_by(User, email: offer.target_email) |> Repo.preload(:startpacks)
    loan_out = contractor.startpacks.use_loan_out_company?
    daily_construction_loan_out = offer.daily_or_weekly == "daily" && Enum.member?(project_documents, "DAILY CONSTRUCTION LOAN OUT")
    daily_transport_loan_out = offer.daily_or_weekly == "daily" && Enum.member?(project_documents, "DAILY TRANSPORT LOAN OUT")
    daily = offer.daily_or_weekly == "daily"
    contract_type =
      case loan_out do
        true ->
          case offer do
            %{department: "Construction"} ->
              case daily_construction_loan_out do
                true -> "DAILY CONSTRUCTION LOAN OUT"
                false -> "CONSTRUCTION LOAN OUT"
              end
            %{department: "Transport"} ->
              case daily_transport_loan_out do
                true -> "DAILY TRANSPORT LOAN OUT"
                false -> "TRANSPORT LOAN OUT"
              end
            _else ->
              case daily do
                true -> "DAILY LOAN OUT"
                false -> "LOAN OUT"
              end
          end
          false ->
            offer.contract_type
          end
    updated_offer = Repo.update!(Ecto.Changeset.change(offer, %{contract_type: contract_type}))

    # get the relevant original forms for merging
    form_query = Engine.Controllers.Helpers.get_forms_for_merging(updated_offer)
    contract_documents = Repo.all(form_query)
    form_documents =
      Repo.all(project_documents(project))
      |> Enum.filter(fn document -> document.category == "Form" end)

    documents = contract_documents ++ form_documents

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
            |> put_flash(:error, "Error making response")
            |> redirect(to: project_offer_path(conn, :show, offer.project_id, offer))
          {:ok, offer} ->
            Engine.Email.send_offer_response_pm(conn, offer, project, contractor)
            |> Engine.Mailer.deliver_later()

            case offer.accepted do
              false ->
                conn
                |> put_flash(:info, "Offer rejected")
                |> redirect(to: project_offer_path(conn, :show, offer.project_id, offer))
              true ->
                initial_contract_type = offer.contract_type

                Engine.Email.send_offer_accepted_contractor(conn, updated_offer, contractor)
                |> Engine.Mailer.deliver_later()


                # now merge data
                case Merger.merge_multiple(updated_offer, documents) do
                  {:error, msg} ->
                    # Un-accept the offer so they can accept again when changes have been made
                    Repo.update(Ecto.Changeset.change(offer, %{accepted: nil}))
                    Repo.update(Ecto.Changeset.change(offer, %{contract_type: initial_contract_type}))
                    conn
                    |> put_flash(:error, msg)
                    |> redirect(to: project_offer_path(conn, :show, offer.project_id, offer))
                  {:ok, _msg} ->
                    # reply to user
                    conn
                    |> put_flash(:info, "Congratulations, you have accepted this offer")
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
    |> put_flash(:info, "Offer deleted successfully")
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
    # integers = ["fee_per_day_inc_holiday"]
    floats = ["working_week", "sixth_day_fee_multiplier", "seventh_day_fee_multiplier"]
    fee_per_day_inc_holiday = Map.get(offer_params, "fee_per_day_inc_holiday")
    offer_params =
      offer_params
      |> update_keys(floats, &String.to_float/1)
      |> Map.put("fee_per_day_inc_holiday", make_float(fee_per_day_inc_holiday))
    offer_params
  end

  defp make_float(number_string) do
    case number_string =~ "." do
      true -> String.to_float(number_string)
      false -> String.to_integer(number_string) / 1
    end
  end

  defp update_keys(params, keys, f) do
    # map over the keys of params, applying function f to each of the keys given
    Enum.reduce(keys, params, fn(i, acc) -> Map.update!(acc, i, f) end)
  end

  def run_calculations(params, project, project_documents, daily, equipment) do
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
    contract_type = determine_contract_type(department, job_title, project_documents, daily, equipment)
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
