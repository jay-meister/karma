defmodule Karma.Repo.Migrations.UndoNilify do
  use Ecto.Migration

  def change do
    alter table(:altered_documents) do
      remove :document_id
      add :document_id, references(:documents, on_delete: :nothing)
    end
  end
end
