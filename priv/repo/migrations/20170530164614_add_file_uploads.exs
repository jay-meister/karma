defmodule Karma.Repo.Migrations.AddFileUploads do
  use Ecto.Migration

  def change do
    create table(:file_uploads) do
      add :file_url, :string
      add :type, :string
      add :project_id, references(:projects, on_delete: :delete_all)

      timestamps()
    end

    create_index(:file_uploads, [:project_id])
  end
end
