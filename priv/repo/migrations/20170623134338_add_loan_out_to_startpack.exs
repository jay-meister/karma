defmodule Karma.Repo.Migrations.AddLoanOutToStartpack do
  use Ecto.Migration

  def change do
    alter table(:startpacks) do
      add :use_loan_out_company?, :boolean
    end
  end
end
