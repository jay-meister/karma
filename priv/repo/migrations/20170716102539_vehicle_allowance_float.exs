defmodule Engine.Repo.Migrations.VehicleAllowanceFloat do
  use Ecto.Migration

  def change do
    alter table(:offers) do
      modify :vehicle_allowance_per_week, :float
    end
  end
end
