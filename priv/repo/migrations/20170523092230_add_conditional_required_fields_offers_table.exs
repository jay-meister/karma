defmodule Karma.Repo.Migrations.AddConditionalRequiredFieldsOffersTable do
  use Ecto.Migration

  def change do
    alter table(:offers) do
      add :box_rental_required?, :boolean
      add :equipment_rental_required?, :boolean
    end
  end
end
