defmodule Karma.SigneeTest do
  use Karma.ModelCase

  alias Karma.Signee

  @valid_attrs %{name: "First Last", email: "test@email.com", role: "Role"}
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