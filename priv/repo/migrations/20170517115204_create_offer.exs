defmodule Engine.Repo.Migrations.CreateOffer do
  use Ecto.Migration

  def change do
    create table(:offers) do
      add :target_email, :string
      add :department, :string
      add :job_title, :string
      add :contract_type, :string
      add :start_date, :date
      add :daily_or_weekly, :string
      add :working_week, :float
      add :currency, :string
      add :overtime_rate_per_hour, :integer
      add :other_deal_provisions, :text
      add :box_rental_description, :text
      add :box_rental_fee_per_week, :integer
      add :box_rental_cap, :integer
      add :box_rental_period, :string
      add :equipment_rental_description, :string
      add :equipment_rental_fee_per_week, :integer
      add :equipment_rental_cap, :integer
      add :equipment_rental_period, :string
      add :vehicle_allowance_per_week, :integer
      add :fee_per_day_inc_holiday, :integer
      add :fee_per_day_exc_holiday, :integer
      add :fee_per_week_inc_holiday, :integer
      add :fee_per_week_exc_holiday, :integer
      add :holiday_pay_per_day, :integer
      add :holiday_pay_per_week, :integer
      add :sixth_day_fee, :float
      add :seventh_day_fee, :float
      add :additional_notes, :text
      add :accepted, :boolean, default: nil
      add :active, :boolean, default: true
      add :contractor_details_accepted, :boolean, default: nil
      add :user_id, references(:users, on_delete: :nothing)
      add :project_id, references(:projects, on_delete: :nothing)

      timestamps()
    end
    create index(:offers, [:user_id])
    create index(:offers, [:project_id])

  end
end
