defmodule Karma.Document do
  use Karma.Web, :model

  schema "documents" do
    field :url, :string
    field :category, :string
    field :name, :string
    belongs_to :project, Karma.Project
    many_to_many :signees, Karma.Signee, join_through: "documents_signees"

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:url, :category, :name])
    |> validate_required([:url, :category, :name])
  end


  def is_pdf?(file_params) do
    file_params.content_type == "application/pdf"
  end
end
