defmodule Karma.TestHelpers do
  alias Karma.{Repo, User, Project, Offer}

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


  def insert_offer(project, attrs \\ %{}) do
    changes = Map.merge(default_offer(), attrs)

    project
    |> Ecto.build_assoc(:offers, %{})
    |> Offer.changeset(changes)
    |> Repo.insert!
  end

  def default_project (attrs \\ %{}) do
    default = %{active: true,
      additional_notes: "",
      budget: "big",
      codename: "Finickity Spicket",
      company_address_1: "22 Birchmore",
      company_address_2: "Mossy Nill",
      company_address_city: "London",
      company_address_postcode: "N7 4TB",
      company_address_country: "UK",
      company_name: "Varner",
      description: "A new film",
      duration: 12,
      holiday_rate: 0.1077,
      locations: "London, Paris",
      name: "Mission Impossible 10",
      operating_base_address_1: "22 Birchmore",
      operating_base_address_2: "Mossy Nill",
      operating_base_address_city: "London",
      operating_base_address_postcode: "N7 4TB",
      operating_base_address_country: "UK",
      start_date: %{"day" => 1, "month" => 1, "year" => 2018},
      studio_name: "Warner",
      type: "feature"
    }
    Map.merge(default, attrs)
  end

  def default_offer(attrs \\ %{}) do
    default = %{accepted: nil,
      active: true,
      additional_notes: "You will be allowed 3 days leave",
      box_rental_cap: 42000,
      box_rental_description: "n/a",
      box_rental_fee_per_week: 4200,
      box_rental_period: "from 10/01/19 for 3 weeks",
      contract_type: "PAYE",
      contractor_details_accepted: true,
      currency: "GBP",
      daily_or_weekly: "daily",
      department: "Accounts",
      equipment_rental_cap: 0,
      equipment_rental_description: "n/a",
      equipment_rental_fee_per_week: 0,
      equipment_rental_period: "n/a",
      fee_per_day_inc_holiday: 4200,
      job_title: "Cashier",
      other_deal_provisions: "n/a",
      overtime_rate_per_hour: 1000,
      seventh_day_fee: 6000,
      sixth_day_fee: 5000,
      start_date: %{day: 17, month: 4, year: 2019},
      target_email: "a_new_email@gmail.com",
      vehicle_allowance_per_week: 0,
      working_week: 5.5
    }
    Map.merge(default, attrs)
  end
end
