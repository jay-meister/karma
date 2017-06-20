defmodule Karma.Repo.Migrations.CreateDocumentsSigneesJoinTable do
  use Ecto.Migration

  def change do
    create table(:documents_signees, primary_key: false) do
      add :document_id, references(:documents, on_delete: :nilify_all)
      add :signee_id, references(:signees, on_delete: :nilify_all)
      add :order, :integer
    end
  end
end
