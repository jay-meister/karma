defmodule Karma.Repo.Migrations.AddVehicleRequiredToStartpack do
  use Ecto.Migration

  def change do
    alter table(:startpacks) do
      add :vehicle_bring_own?, :boolean
    end
  end
end
