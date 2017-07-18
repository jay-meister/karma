defmodule Engine.Repo.Migrations.AddTermsAndConditions do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :terms_accepted, :boolean, default: false
    end
  end
end
