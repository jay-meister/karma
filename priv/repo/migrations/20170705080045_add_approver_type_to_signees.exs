defmodule Engine.Repo.Migrations.AddApproverTypeToSignees do
  use Ecto.Migration

  def change do
    alter table(:signees) do
      add :approver_type, :string
    end
  end
end
