defmodule Engine.Repo.Migrations.AddJobTitleSuffixToOffer do
  use Ecto.Migration

  def change do
    alter table(:offers) do
      add :job_title_suffix, :string
    end
  end
end
