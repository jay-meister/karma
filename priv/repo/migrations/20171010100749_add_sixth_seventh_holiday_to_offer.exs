defmodule Engine.Repo.Migrations.AddSixthSeventhHolidayToOffer do
  use Ecto.Migration

  def change do
    alter table(:offers) do
      add :sixth_day_holiday_pay, :float
      add :seventh_day_holiday_pay, :float
    end
  end
end
