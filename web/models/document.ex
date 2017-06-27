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


  # get contract related to this offer
  def get_contract(query, offer, loan_out) do
    case loan_out do
      true ->
        from d in query,
        or_where: d.project_id == ^offer.project_id
        and d.name == "LOAN OUT"
      false ->
        from d in query,
        or_where: d.project_id == ^offer.project_id
        and d.name == ^offer.contract_type
    end
  end

  def get_conditional_form(query, offer, checker, form_name) do
    if checker do
      from d in query,
      or_where: d.project_id == ^offer.project_id
      and d.name == ^form_name
    else
      query
    end
  end

end
