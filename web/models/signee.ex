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
    |> cast(params, [:name, :role, :email])
    |> validate_required([:name, :role, :email])
    |> email_changeset(params)
  end

  def email_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
  end

end
