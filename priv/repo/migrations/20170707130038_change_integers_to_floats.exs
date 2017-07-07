defmodule Karma.Repo.Migrations.ChangeIntegersToFloats do
  use Ecto.Migration

  def change do
    alter table(:offers) do
      modify :fee_per_day_inc_holiday, :float
      modify :fee_per_day_exc_holiday, :float
      modify :fee_per_week_inc_holiday, :float
      modify :fee_per_week_exc_holiday, :float
      modify :holiday_pay_per_day, :float
      modify :holiday_pay_per_week, :float
      modify :box_rental_fee_per_week, :float
      modify :box_rental_cap, :float
      modify :equipment_rental_fee_per_week, :float
      modify :equipment_rental_cap, :float
    end
  end
end
