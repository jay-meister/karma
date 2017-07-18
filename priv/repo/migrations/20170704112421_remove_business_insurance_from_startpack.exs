defmodule Engine.Repo.Migrations.RemoveBusinessInsuranceFromStartpack do
  use Ecto.Migration

  def change do
    alter table(:startpacks) do
      remove :vehicle_business_use_insurance_url
    end
  end
end
