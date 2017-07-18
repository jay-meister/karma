defmodule Engine.Repo.Migrations.CreateSignee do
  use Ecto.Migration

  def change do
    create table(:signees) do
      add :name, :string
      add :role, :string
      add :project_id, references(:projects, on_delete: :delete_all)

      timestamps()
    end
    create index(:signees, [:project_id])

  end
end
