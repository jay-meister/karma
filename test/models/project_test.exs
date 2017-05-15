defmodule Karma.ProjectTest do
  use Karma.ModelCase

  alias Karma.Project

  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Project.changeset(%Project{}, default_project(%{user_id: 1}))
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Project.changeset(%Project{}, @invalid_attrs)
    refute changeset.valid?
  end
end
