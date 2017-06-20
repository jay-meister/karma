defmodule Karma.Repo.Migrations.SplitDocumentsTables do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      remove :offer_id
    end

    create table(:altered_documents) do
      add :offer_id, references(:offers, on_delete: :nothing)
      add :document_id, references(:documents, on_delete: :nothing)
      add :status, :string
      add :merged_url, :string
      add :signed_url, :string
      add :envelope_id, :string

      timestamps()
    end

  end
end
