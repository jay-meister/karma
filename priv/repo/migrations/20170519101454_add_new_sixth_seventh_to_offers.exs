defmodule Karma.Repo.Migrations.AddNewSixthSeventhToOffers do
  use Ecto.Migration

  def change do
    rename table(:offers), :sixth_day_fee, to: :sixth_day_fee_inc_holiday
    rename table(:offers), :seventh_day_fee, to: :seventh_day_fee_inc_holiday
    alter table(:offers) do
      add :sixth_day_fee_exc_holiday, :float
      add :seventh_day_fee_exc_holiday, :float
    end
  end
end
