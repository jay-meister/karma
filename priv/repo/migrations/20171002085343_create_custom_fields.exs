defmodule Engine.Repo.Migrations.CreateCustomFields do
  use Ecto.Migration

  def change do
    create table(:custom_fields) do
      add :name, :string
      add :value, :string
      add :type, :string
      add :project_id, references(:projects, on_delete: :delete_all)
      add :offer_id, references(:offers, on_delete: :delete_all)

      timestamps()
    end
    create index(:custom_fields, [:project_id])
    create index(:custom_fields, [:offer_id])
    
  end
end
