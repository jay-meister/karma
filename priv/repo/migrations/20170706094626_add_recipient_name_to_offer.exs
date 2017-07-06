defmodule Karma.Repo.Migrations.AddRecipientNameToOffer do
  use Ecto.Migration

  def change do
    alter table(:offers) do
      add :recipient_fullname, :string
    end
  end
end
