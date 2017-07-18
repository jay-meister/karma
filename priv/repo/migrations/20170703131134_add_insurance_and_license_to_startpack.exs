defmodule Engine.Repo.Migrations.AddInsuranceAndLicenseToStartpack do
  use Ecto.Migration

  def change do
    alter table(:startpacks) do
      add :vehicle_business_use_insurance_url, :string
      add :vehicle_license_url, :string
    end
  end
end
