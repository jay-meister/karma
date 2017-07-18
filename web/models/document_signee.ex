defmodule Engine.DocumentSignee do
  use Engine.Web, :model

  @primary_key false
  schema "documents_signees" do
    field :order, :integer
    belongs_to :document, Engine.Document
    belongs_to :signee, Engine.Signee
  end

  def changeset(struct, params \\ :invalid) do
    struct
    |> cast(params, [:document_id, :signee_id, :order])
    |> validate_required([:document_id, :signee_id, :order])
  end
end
