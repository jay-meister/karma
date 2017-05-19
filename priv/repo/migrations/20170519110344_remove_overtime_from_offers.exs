defmodule Karma.Repo.Migrations.RemoveOvertimeFromOffers do
  use Ecto.Migration

  def change do
    alter table(:offers) do
      remove :overtime_rate_per_hour
    end
  end
end
