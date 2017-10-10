defmodule Engine.Repo.Migrations.AlterShootDurationToFloat do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      modify :duration, :float
    end
  end
end
