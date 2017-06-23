defmodule Karma.Signee do
  use Karma.Web, :model

  schema "signees" do
    field :name, :string
    field :role, :string
    field :email, :string
    belongs_to :project, Karma.Project
    many_to_many :documents, Karma.Document, join_through: "documents_signees"

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :role, :email, :project_id])
    |> validate_required([:name, :role, :email, :project_id])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:unique_project_signees, name: :unique_project_signees)
  end

end
