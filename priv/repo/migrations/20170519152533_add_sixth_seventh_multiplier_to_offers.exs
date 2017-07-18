defmodule Engine.Repo.Migrations.AddSixthSeventhMultiplierToOffers do
  use Ecto.Migration

  def change do
    alter table(:offers) do
      add :sixth_day_fee_multiplier, :float
      add :seventh_day_fee_multiplier, :float
    end
  end
end
