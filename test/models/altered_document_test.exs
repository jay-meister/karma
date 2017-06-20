defmodule Karma.AlteredDocumentTest do
  use Karma.ModelCase

  alias Karma.AlteredDocument

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
end
