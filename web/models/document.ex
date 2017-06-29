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
  def get_contract(query, offer) do
    contract_type =
      case offer do
        %{contract_type: "LOAN OUT", department: "Construction"} -> "CONSTRUCTION LOAN OUT"
        %{contract_type: "LOAN OUT", department: "Transport"} -> "TRANSPORT LOAN OUT"
        _else -> offer.contract_type
      end
    from d in query,
    or_where: d.project_id == ^offer.project_id
    and d.name == ^contract_type
  end

  def get_start_form(query, offer) do
    from d in query,
    or_where: d.project_id == ^offer.project_id
    and d.name == "START FORM"
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
