defmodule Engine.Repo.Migrations.AddSentToOffers do
  use Ecto.Migration

  def change do
    alter table(:offers) do
      add :sent, :boolean
    end
  end
end
