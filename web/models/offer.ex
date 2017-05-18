defmodule Karma.Offer do
  use Karma.Web, :model

  schema "offers" do
    field :target_email, :string
    field :department, :string
    field :job_title, :string
    field :contract_type, :string
    field :start_date, Ecto.Date
    field :daily_or_weekly, :string
    field :working_week, :float
    field :currency, :string
    field :overtime_rate_per_hour, :integer
    field :other_deal_provisions, :string
    field :box_rental_description, :string
    field :box_rental_fee_per_week, :integer
    field :box_rental_cap, :integer
    field :box_rental_period, :string
    field :equipment_rental_description, :string
    field :equipment_rental_fee_per_week, :integer
    field :equipment_rental_cap, :integer
    field :equipment_rental_period, :string
    field :vehicle_allowance_per_week, :integer
    field :fee_per_day_inc_holiday, :integer
    field :fee_per_day_exc_holiday, :integer
    field :fee_per_week_inc_holiday, :integer
    field :fee_per_week_exc_holiday, :integer
    field :holiday_pay_per_day, :integer
    field :holiday_pay_per_week, :integer
    field :sixth_day_fee, :float
    field :seventh_day_fee, :float
    field :additional_notes, :string
    field :accepted, :boolean, default: nil
    field :active, :boolean, default: true
    field :contractor_details_accepted, :boolean, default: nil
    belongs_to :user, Karma.User
    belongs_to :project, Karma.Project

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :target_email,
      :department,
      :job_title,
      :contract_type,
      :start_date,
      :daily_or_weekly,
      :working_week,
      :currency,
      :overtime_rate_per_hour,
      :other_deal_provisions,
      :box_rental_description,
      :box_rental_fee_per_week,
      :box_rental_cap,
      :box_rental_period,
      :equipment_rental_description,
      :equipment_rental_fee_per_week,
      :equipment_rental_cap,
      :equipment_rental_period,
      :vehicle_allowance_per_week,
      :fee_per_day_inc_holiday,
      :fee_per_day_exc_holiday,
      :fee_per_week_inc_holiday,
      :fee_per_week_exc_holiday,
      :holiday_pay_per_day,
      :holiday_pay_per_week,
      :sixth_day_fee,
      :seventh_day_fee,
      :additional_notes,
      :accepted,
      :active,
      :contractor_details_accepted,
      :project_id,
      :user_id])
    |> validate_required([
      :target_email,
      :department,
      :job_title,
      :contract_type,
      :start_date,
      :daily_or_weekly,
      :working_week,
      :currency,
      :overtime_rate_per_hour,
      :other_deal_provisions,
      :box_rental_description,
      :box_rental_fee_per_week,
      :box_rental_cap,
      :box_rental_period,
      :equipment_rental_description,
      :equipment_rental_fee_per_week,
      :equipment_rental_cap,
      :equipment_rental_period,
      :vehicle_allowance_per_week,
      :fee_per_day_inc_holiday,
      :sixth_day_fee,
      :seventh_day_fee,
      :active,
      :project_id
      ])
  end

  # queries
  # get projects created by specified user
  def projects_offers(query, project) do
    from p in query,
    where: p.project_id == ^project.id
  end
end
