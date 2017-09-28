defmodule Engine.Repo.Migrations.AddOperatingContactToProject do
  use Ecto.Migration

  def change do
    alter table(:projects) do
       add :operating_base_tel, :string
       add :operating_base_email, :string
    end
  end
end
