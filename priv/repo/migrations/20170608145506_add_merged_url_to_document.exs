defmodule Karma.Repo.Migrations.AddMergedUrlToDocument do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      add :merged_url, :string
      add :offer_id, references(:offers, on_delete: :delete_all)
    end

    create index(:documents, [:offer_id])
  end
end
