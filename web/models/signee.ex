defmodule Engine.Signee do
  use Engine.Web, :model

  schema "signees" do
    field :name, :string
    field :role, :string
    field :email, :string
    field :approver_type, :string
    belongs_to :project, Engine.Project
    many_to_many :documents, Engine.Document, join_through: "documents_signees"

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :role, :email, :approver_type, :project_id])
    |> validate_required([:name, :role, :email, :approver_type, :project_id])
    |> validate_inclusion(:approver_type, ["Approver", "Recipient"])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:unique_project_signees, name: :unique_project_signees)
  end

end
