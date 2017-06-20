defmodule Karma.Signee do
  use Karma.Web, :model

  schema "signees" do
    field :name, :string
    field :role, :string
    field :email, :string
    belongs_to :project, Karma.Project

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :role, :email, :project_id])
    |> validate_required([:name, :role, :email, :project_id])
    |> validate_format(:email, ~r/@/)
  end
  
end
