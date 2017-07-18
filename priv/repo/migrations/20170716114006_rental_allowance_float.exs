defmodule Engine.Repo.Migrations.RentalAllowanceFloat do
  use Ecto.Migration

  def change do
    alter table(:startpacks) do
      modify :equipment_rental_value, :float
      modify :box_rental_value, :float
    end
  end
end
