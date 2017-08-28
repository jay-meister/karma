defmodule Engine.Repo.Migrations.LaonOutAddressTextArea do
  use Ecto.Migration

  def change do
    alter table(:startpacks) do
      modify :loan_out_company_address, :string
    end
  end
end
