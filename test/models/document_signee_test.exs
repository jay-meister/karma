defmodule Engine.DocumentSigneeTest do
  use Engine.ModelCase

  alias Engine.DocumentSignee

  @valid_attrs %{document_id: 1, signee_id: 1, order: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = DocumentSignee.changeset(%DocumentSignee{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = DocumentSignee.changeset(%DocumentSignee{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "document signee schema" do
    actual = DocumentSignee.__schema__(:fields)
    expected = [:order, :document_id, :signee_id]

    assert actual == expected
  end
end
