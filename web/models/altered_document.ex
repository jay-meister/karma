defmodule Karma.AlteredDocument do
  use Karma.Web, :model

  schema "altered_documents" do
    belongs_to :offer, Karma.Offer
    belongs_to :document, Karma.Document
    field :status, :string
    field :merged_url, :string
    field :signed_url, :string
    field :envelope_id, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:offer_id, :document_id, :merged_url, :status, :envelope_id, :signed_url])
    |> validate_required([:offer_id, :document_id, :merged_url])
  end

  def merged_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> put_change(:status, "merged")
    |> validate_required([:status])
  end

  def signing_started_changeset(struct, params \\ %{}) do
    struct
    |> changeset(params)
    |> put_change(:status, "signing")
    |> validate_required([:envelope_id, :status])
  end

  # def signing_completed_changeset(struct, params \\ %{}) do
  #   struct
  #   |> changeset(params)
  #   |> put_change(:status, "signed")
  #   |> validate_required([:envelope_id, :signed_url])
  # end
end
