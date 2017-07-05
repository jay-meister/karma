defmodule Karma.Repo.Migrations.NilifyDocuments do
  use Ecto.Migration

  def change do
    alter table(:altered_documents) do
      remove :document_id
      add :document_id, references(:documents, on_delete: :nilify_all)
    end
  end
end
