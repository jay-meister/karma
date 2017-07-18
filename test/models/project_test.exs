defmodule Engine.ProjectTest do
  use Engine.ModelCase

  alias Engine.Project

  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Project.changeset(%Project{}, default_project(%{user_id: 1}))
    assert changeset.valid?
  end

  test "changeset with invalid type" do
    changeset = Project.changeset(%Project{}, default_project(%{type: "Feature"}))
    refute changeset.valid?
  end
  test "changeset with invalid holiday rate" do
    changeset = Project.changeset(%Project{}, default_project(%{holiday_rate: 0.1078}))
    refute changeset.valid?
  end
  test "changeset with invalid budget" do
    changeset = Project.changeset(%Project{}, default_project(%{budget: "huge"}))
    refute changeset.valid?
  end
  test "changeset with invalid attributes" do
    changeset = Project.changeset(%Project{}, @invalid_attrs)
    refute changeset.valid?
  end
end
