defmodule Engine.Repo.Migrations.AddEmailToSignee do
  use Ecto.Migration

  def change do
    alter table(:signees) do
      add :email, :string
    end
  end
end
