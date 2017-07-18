defmodule Engine.AlteredDocumentTest do
  use Engine.ModelCase

  alias Engine.AlteredDocument

  @valid_attrs %{offer_id: 1, document_id: 1, merged_url: "www.aws.com", status: "merged"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = AlteredDocument.changeset(%AlteredDocument{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = AlteredDocument.changeset(%AlteredDocument{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "altered_document schema" do
    actual = AlteredDocument.__schema__(:fields)
    expected = [:id, :offer_id, :document_id, :status, :merged_url, :signed_url, :envelope_id, :inserted_at, :updated_at]

    assert actual == expected
 end
end
