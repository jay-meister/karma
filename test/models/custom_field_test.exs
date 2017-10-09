defmodule Engine.CustomFieldTest do
  use Engine.ModelCase

  alias Engine.CustomField

  @valid_value_attrs %{offer_id: 1, project_id: 1, name: "Shoot day duration", value: "12 hours", type: "Project"}
  @valid_attrs %{offer_id: 1, project_id: 1, name: "Shoot day duration", type: "Offer"}
  @invalid_attrs %{}

  test "value changeset with valid attributes" do
    changeset = CustomField.value_changeset(%CustomField{}, @valid_value_attrs)
    assert changeset.valid?
  end

  test "value changeset with invalid attributes" do
    changeset = CustomField.value_changeset(%CustomField{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset with valid attributes" do
    changeset = CustomField.changeset(%CustomField{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = CustomField.changeset(%CustomField{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "altered_document schema" do
    actual = CustomField.__schema__(:fields)
    expected = [:id, :name, :value, :type, :offer_id, :project_id, :inserted_at, :updated_at]

    assert actual == expected
 end
end
