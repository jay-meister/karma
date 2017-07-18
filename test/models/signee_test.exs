defmodule Engine.SigneeTest do
  use Engine.ModelCase

  alias Engine.Signee

  @valid_attrs %{name: "First Last", email: "test@email.com", approver_type: "Approver", role: "Role", project_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Signee.changeset(%Signee{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Signee.changeset(%Signee{}, @invalid_attrs)
    refute changeset.valid?
  end
end
