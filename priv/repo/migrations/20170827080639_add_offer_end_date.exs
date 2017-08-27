defmodule Engine.Repo.Migrations.AddOfferEndDate do
  use Ecto.Migration

  def change do
    alter table(:offers) do
      add :end_date, :date
    end
  end
end
