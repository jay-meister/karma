defmodule Karma.StartpackTest do
  use Karma.ModelCase

  alias Karma.Startpack

  @valid_attrs %{
    passport_expiry_date: %{day: 17, month: 4, year: 2010},
    country_of_legal_nationality: "some content",
    mobile_tel: "some content",
    vehicle_colour: "some content",
    emergency_contact_name: "some content",
    emergency_contact_tel: "some content",
    bank_account_number: "some content",
    emergency_contact_relationship: "some content",
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
    passport_full_name: "some content",
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
    bank_swift_code: "some content",
    date_of_birth: %{day: 17, month: 4, year: 2010},
    place_of_birth: "some content",
    screen_credit_name: "some content",
    primary_address_1: "some content",
    primary_address_city: "some content",
    passport_number: "some content",
    passport_url:  "some content",
    }
    @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Startpack.changeset(%Startpack{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Startpack.changeset(%Startpack{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "base changeset for validating startpack with missing basic required data" do
    invalid = Map.update(@valid_attrs, %{passport_url: ""})
    changeset = Startpack.base_requirement_changeset(%Startpack{}, invalid)
    refute changeset.valid?
  end
  
  test "base changeset for validating startpack with valid basic data" do
    changeset = Startpack.base_requirement_changeset(%Startpack{}, @valid_attrs)
    assert changeset.valid?
  end
end
