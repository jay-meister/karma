defmodule Engine.Repo.Migrations.AddLoanOutCompanyEmail do
  use Ecto.Migration

  def change do
    alter table(:startpacks) do
      add :loan_out_company_email, :string
    end
  end
end
