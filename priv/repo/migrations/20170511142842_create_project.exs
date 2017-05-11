defmodule Karma.Repo.Migrations.CreateProject do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :type, :string
      add :budget, :string
      add :name, :string
      add :codename, :string
      add :description, :text
      add :start_date, :date
      add :duration, :integer
      add :studio_name, :string
      add :company_name, :string
      add :company_address_1, :string
      add :company_address_2, :string
      add :company_address_3, :string
      add :company_address_4, :string
      add :company_address_5, :string
      add :operating_base_address_1, :string
      add :operating_base_address_2, :string
      add :operating_base_address_3, :string
      add :operating_base_address_4, :string
      add :operating_base_address_5, :string
      add :locations, :string
      add :holiday_rate, :float
      add :additional_notes, :text
      add :active, :boolean, default: true, null: false
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:projects, [:user_id])
  end
end
