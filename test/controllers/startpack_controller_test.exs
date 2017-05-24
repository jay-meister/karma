defmodule Karma.StartpackControllerTest do
  use Karma.ConnCase

  alias Karma.Startpack
  @valid_attrs %{
    passport_expiry_date: %{day: 17, month: 4, year: 2010},
    country_of_legal_nationality: "some content",
    mobile_tel: "some content",
    vehicle_colour: "some content",
    emergency_contact_name: "some content",
    emergency_contact_tel: "some content",
    bank_account_number: "some content",
    bank_sort_code: "some content",
    loan_out_company_address: "some content",
    agent_bank_name: "some content",
    gender: "some content",
    student_loan_not_repayed?: true,
    equipment_rental_value: 42,
    country_of_permanent_residence: "some content",
    primary_address_postcode: "some content",
    bank_name: "some content",
    bank_account_users_full_name: "some content",
    box_rental_url: "some content",
    agent_name: "some content",
    box_rental_value: 42,
    vat_number: "some content",
    vehicle_registration: "some content",
    agent_bank_account_iban: "some content",
    loan_out_company_cert_url: "some content",
    middle_names: "some content",
    agent_bank_account_swift_code: "some content",
    for_paye_only: "some content",
    agent_email_address: "some content",
    schedule_d_letter_url: "some content",
    p45_url: "some content",
    agent_bank_sort_code: "some content",
    vehicle_make: "some content",
    bank_address: "some content",
    national_insurance_number: "some content",
    passport_issuing_country: "some content",
    agent_bank_address: "some content",
    equipment_rental_url: "some content",
    agent_deal?: true,
    student_loan_repay_direct?: true,
    bank_swift_code: "some content",
    vehicle_model: "some content",
    primary_address_country: "some content",
    full_name_as_on_passport: "some content",
    agent_tel: "some content",
    vehicle_insurance_url: "some content",
    student_loan_finished_before_6_april?: true,
    agent_company: "some content",
    primary_address_2: "some content",
    loan_out_company_registration_number: "some content",
    loan_out_company_address: "some content",
    loan_out_company_cert_url: "some content",
    bank_name: "some content",
    bank_address: "some content",
    bank_account_users_full_name: "some content",
    bank_account_number: "some content",
    bank_sort_code: "some content",
    bank_iban: "some content",
    bank_swift_code: "some content"
    }
  @invalid_attrs %{}


  setup do
    user = insert_user()
    project = insert_project(user)
    conn = login_user(build_conn(), user)
    {:ok, conn: conn, user: user, project: project}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, startpack_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing startpacks"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, startpack_path(conn, :new)
    assert html_response(conn, 200) =~ "New startpack"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, startpack_path(conn, :create), startpack: @valid_attrs
    assert redirected_to(conn) == startpack_path(conn, :index)
    assert Repo.get_by(Startpack, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, startpack_path(conn, :create), startpack: @invalid_attrs
    assert html_response(conn, 200) =~ "New startpack"
  end

  test "shows chosen resource", %{conn: conn} do
    startpack = Repo.insert! %Startpack{}
    conn = get conn, startpack_path(conn, :show, startpack)
    assert html_response(conn, 200) =~ "Show startpack"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, startpack_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    startpack = Repo.insert! %Startpack{}
    conn = get conn, startpack_path(conn, :edit, startpack)
    assert html_response(conn, 200) =~ "Edit startpack"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    startpack = Repo.insert! %Startpack{}
    conn = put conn, startpack_path(conn, :update, startpack), startpack: @valid_attrs
    assert redirected_to(conn) == startpack_path(conn, :show, startpack)
    assert Repo.get_by(Startpack, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    startpack = Repo.insert! %Startpack{}
    conn = put conn, startpack_path(conn, :update, startpack), startpack: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit startpack"
  end

  test "deletes chosen resource", %{conn: conn} do
    startpack = Repo.insert! %Startpack{}
    conn = delete conn, startpack_path(conn, :delete, startpack)
    assert redirected_to(conn) == startpack_path(conn, :index)
    refute Repo.get(Startpack, startpack.id)
  end
end
