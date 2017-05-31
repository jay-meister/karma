defmodule Karma.Document do
  use Karma.Web, :model

  schema "documents" do
    field :url, :string
    field :category, :string
    belongs_to :project, Karma.Project

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:url, :category])
    |> validate_required([:url, :category])
  end
end
