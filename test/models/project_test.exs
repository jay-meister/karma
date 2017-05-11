defmodule Karma.ProjectTest do
  use Karma.ModelCase

  alias Karma.Project

  @valid_attrs %{active: true, additional_notes: "some content", budget: "some content", codename: "some content", company_address_1: "some content", company_address_2: "some content", company_address_3: "some content", company_address_4: "some content", company_address_5: "some content", company_name: "some content", description: "some content", duration: 42, holiday_rate: "120.5", locations: "some content", name: "some content", operating_base_address_1: "some content", operating_base_address_2: "some content", operating_base_address_3: "some content", operating_base_address_4: "some content", operating_base_address_5: "some content", start_date: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, studio_name: "some content", type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Project.changeset(%Project{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Project.changeset(%Project{}, @invalid_attrs)
    refute changeset.valid?
  end
end
