defmodule Engine.CustomField do
  use Engine.Web, :model

  schema "custom_fields" do
    field :name, :string
    field :value, :string
    field :type, :string
    belongs_to :offer, Engine.Offer
    belongs_to :project, Engine.Project

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :value, :type])
    |> validate_required([:name, :type])
  end

  def value_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> validate_required([:value])
  end
end
