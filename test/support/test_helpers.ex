defmodule Karma.TestHelpers do
  alias Karma.{Repo, User, Project}

  @user_id 1

  def id() do
    %{user: @user_id}
  end

  def insert_user(attrs \\ %{}) do
    changes = Map.merge(
      %{first_name: "Joe",
        last_name: "Blogs",
        email: "test@test.com",
        password: "123456",
        terms_accepted: true,
        verified: true},
        attrs)

    %User{}
    |> User.registration_changeset(changes)
    |> Repo.insert!
  end

  def login_user(conn, user) do
      conn
      |> Plug.Conn.assign(:current_user, user)
  end

  def insert_project(user, attrs \\ %{}) do
  changes = Map.merge(default_project(), attrs)

  user
  |> Ecto.build_assoc(:projects, %{})
  |> Project.changeset(changes)
  |> Repo.insert!
  end

  def default_project do
    %{ active: true,
      additional_notes: "some content",
      budget: "high",
      codename: "Finickity Spicket",
      company_address_1: "22 Birchmore",
      company_address_2: "London",
      company_address_city: "N7 4TB",
      company_address_postcode: "UK",
      company_address_country: "",
      company_name: "Varner",
      description: "A new film",
      duration: 12,
      holiday_rate: 0.1077,
      locations: "London, Paris",
      name: "Mission Impossible 10",
      operating_base_address_1: "22 Birchmore",
      operating_base_address_2: "London",
      operating_base_address_city: "N7 4TB",
      operating_base_address_postcode: "UK",
      operating_base_address_country: "",
      start_date: %{"day" => 1, "month" => 1, "year" => 2019},
      studio_name: "Warner",
      type: "feature"
    }
  end
end
