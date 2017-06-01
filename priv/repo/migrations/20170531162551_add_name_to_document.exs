defmodule Karma.Repo.Migrations.AddNameToDocument do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      add :name, :string
    end
  end
end
