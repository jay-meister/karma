defmodule :"Elixir.Engine.Repo.Migrations.Add-signee-project-unique-index" do
  use Ecto.Migration

  def change do
    create unique_index(:signees, [:project_id, :email], name: :unique_project_signees)
  end
end
