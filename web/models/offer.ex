defmodule Engine.Offer do
  use Engine.Web, :model

  schema "offers" do
    field :recipient_fullname, :string
    field :target_email, :string
    field :department, :string
    field :job_title, :string
    field :contract_type, :string
    field :start_date, Ecto.Date
    field :end_date, Ecto.Date
    field :daily_or_weekly, :string
    field :working_week, :float
    field :currency, :string
    field :other_deal_provisions, :string
    field :box_rental_required?, :boolean
    field :box_rental_description, :string
    field :box_rental_fee_per_week, :float
    field :box_rental_cap, :float
    field :box_rental_period, :string
    field :equipment_rental_required?, :boolean
    field :equipment_rental_description, :string
    field :equipment_rental_fee_per_week, :float
    field :equipment_rental_cap, :float
    field :equipment_rental_period, :string
    field :vehicle_allowance_per_week, :float, default: 0
    field :fee_per_day_inc_holiday, :float
    field :fee_per_day_exc_holiday, :float
    field :fee_per_week_inc_holiday, :float
    field :fee_per_week_exc_holiday, :float
    field :holiday_pay_per_day, :float
    field :holiday_pay_per_week, :float
    field :sixth_day_fee_inc_holiday, :float
    field :sixth_day_fee_exc_holiday, :float
    field :sixth_day_fee_multiplier, :float
    field :seventh_day_fee_inc_holiday, :float
    field :seventh_day_fee_exc_holiday, :float
    field :seventh_day_fee_multiplier, :float
    field :additional_notes, :string
    field :accepted, :boolean, default: nil
    field :active, :boolean, default: true
    field :contractor_details_accepted, :boolean, default: nil
    belongs_to :user, Engine.User
    belongs_to :project, Engine.Project
    has_many :altered_documents, Engine.AlteredDocument
    has_many :custom_fields, Engine.CustomField

    timestamps()
  end

  @equipment_rental_fields [
    :equipment_rental_description,
    :equipment_rental_fee_per_week,
    :equipment_rental_cap,
    :equipment_rental_period
    ]

  @box_rental_fields [
    :box_rental_description,
    :box_rental_fee_per_week,
    :box_rental_cap,
    :box_rental_period
  ]

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> form_validation(params)
    |> cast(params, [
      :recipient_fullname,
      :contract_type,
      :fee_per_day_exc_holiday,
      :fee_per_week_inc_holiday,
      :fee_per_week_exc_holiday,
      :holiday_pay_per_day,
      :holiday_pay_per_week,
      :sixth_day_fee_inc_holiday,
      :sixth_day_fee_exc_holiday,
      :sixth_day_fee_multiplier,
      :seventh_day_fee_inc_holiday,
      :seventh_day_fee_exc_holiday,
      :seventh_day_fee_multiplier,
      :additional_notes,
      :accepted,
      :active,
      :contractor_details_accepted,
      :project_id,
      :user_id])
    |> validate_required([
      :recipient_fullname,
      :contract_type,
      :sixth_day_fee_inc_holiday,
      :sixth_day_fee_exc_holiday,
      :seventh_day_fee_inc_holiday,
      :seventh_day_fee_exc_holiday,
      :active,
      :project_id
      ])
    |> validate_required_dropdowns()
  end

  def send_offer_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
  end

  def form_validation(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :recipient_fullname,
      :target_email,
      :department,
      :job_title,
      :start_date,
      :end_date,
      :daily_or_weekly,
      :working_week,
      :currency,
      :other_deal_provisions,
      :vehicle_allowance_per_week,
      :fee_per_day_inc_holiday,
      :sixth_day_fee_multiplier,
      :seventh_day_fee_multiplier,
      :additional_notes,
      :box_rental_required?,
      :box_rental_description,
      :box_rental_fee_per_week,
      :box_rental_cap,
      :box_rental_period,
      :equipment_rental_required?,
      :equipment_rental_description,
      :equipment_rental_fee_per_week,
      :equipment_rental_cap,
      :equipment_rental_period
      ])
    |> validate_required([
      :recipient_fullname,
      :target_email,
      :department,
      :job_title,
      :start_date,
      :daily_or_weekly,
      :working_week,
      :currency,
      :vehicle_allowance_per_week,
      :fee_per_day_inc_holiday,
      :sixth_day_fee_multiplier,
      :seventh_day_fee_multiplier,
      ])
    |> validate_if_required(params, :box_rental_required?, @box_rental_fields)
    |> validate_if_required(params, :equipment_rental_required?, @equipment_rental_fields)
    |> validate_required_dropdowns()
    |> validate_format(:target_email, ~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)
    |> validate_length(:other_deal_provisions, max: 300)
    |> validate_length(:additional_notes, max: 300)
    |> validate_length(:equipment_rental_description, max: 300)
    |> validate_length(:box_rental_description, max: 300)
  end

  def validate_required_dropdowns(changeset) do
    changeset
    |> validate_inclusion(:contract_type, [
      "PAYE",
      "SCHEDULE-D",
      "LOAN OUT",
      "CONSTRUCTION PAYE",
      "CONSTRUCTION SCHEDULE-D",
      "CONSTRUCTION DIRECT HIRE",
      "CONSTRUCTION LOAN OUT",
      "TRANSPORT PAYE",
      "TRANSPORT SCHEDULE-D",
      "TRANSPORT DIRECT HIRE",
      "TRANSPORT LOAN OUT",
      "DIRECT HIRE",
      "DAILY PAYE",
      "DAILY SCHEDULE-D",
      "DAILY LOAN OUT",
      "DAILY CONSTRUCTION PAYE",
      "DAILY CONSTRUCTION SCHEDULE-D",
      "DAILY CONSTRUCTION DIRECT HIRE",
      "DAILY CONSTRUCTION LOAN OUT",
      "DAILY TRANSPORT PAYE",
      "DAILY TRANSPORT SCHEDULE-D",
      "DAILY TRANSPORT DIRECT HIRE",
      "DAILY TRANSPORT LOAN OUT",
      "DAILY DIRECT HIRE"
      ])
    |> validate_inclusion(:daily_or_weekly, ["daily", "weekly"])
    |> validate_inclusion(:working_week, [5.0, 5.5, 6.0])
    |> validate_inclusion(:currency, ["gbp", "eur", "usd"])
    |> validate_inclusion(:sixth_day_fee_multiplier, [1.0, 1.5, 2.0])
    |> validate_inclusion(:seventh_day_fee_multiplier, [1.0, 1.5, 2.0])
  end


  def validate_if_required(changeset, params, check, fields) do
    case Map.get(changeset.changes, check) do
      true ->
        changeset
        |> cast(params, fields)
        |> validate_required(fields)
      _ ->
        changeset
    end
  end

  def offer_response_changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:accepted])
    |> validate_required([:accepted])
  end


  # queries
  # get projects created by specified user
  def projects_offers(query, project) do
    from p in query,
    where: p.project_id == ^project.id
  end

end
