defmodule Engine.Repo.Migrations.AddLoanOutCompanyName do
  use Ecto.Migration

  def change do
    alter table(:startpacks) do
      add :loan_out_company_name, :string
    end
  end
end
