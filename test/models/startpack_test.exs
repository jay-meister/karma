defmodule Engine.StartpackTest do
  use Engine.ModelCase

  alias Engine.Startpack

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
    agent_email_address: "agent@gmail.com",
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
    vehicle_license_url: "some content",
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
    user_id: 1,
    date_of_birth: %{day: 17, month: 4, year: 2010},
    place_of_birth: "some content",
    screen_credit_name: "some content",
    primary_address_1: "some content",
    primary_address_city: "some content",
    passport_number: "some content",
    passport_url:  "some content",
    agent_address: "some content",
    agent_bank_account_number: "some content",
    agent_bank_account_name: "some content"
    }

    @valid_box_attrs %{
      box_rental_url: "box_url.com/image",
      box_rental_value: 2000
    }

    @valid_equipment_attrs %{
      equipment_rental_url: "equipment_url.com/image",
      equipment_rental_value: 2000
    }

    @valid_box_equipment_agent_attrs %{
      equipment_rental_url: "equipment_url.com/image",
      equipment_rental_value: 2000,
      box_rental_url: "box_url.com/image",
      box_rental_value: 2000,
      agent_name: "Agent Smith",
      agent_address: "Agent Address",
      agent_tel: "2345678",
      agent_email_address: "agent@email.com",
      agent_bank_name: "Agent bank",
      agent_bank_address: "Agent bank address",
      agent_bank_sort_code: "123456",
      agent_bank_account_number: "1234567",
      agent_bank_account_name: "MR SMITH",
      agent_deal?: true,
      passport_expiry_date: %{day: 17, month: 4, year: 2010},
      country_of_legal_nationality: "some content",
      mobile_tel: "some content",
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
      vehicle_bring_own?: false,
      vehicle_insurance_url: "some content",
      vehicle_license_url: "some content",
      vehicle_model: "some content",
      vehicle_make: "some content",
      vehicle_colour: "some content",
      vehicle_registration: "some content",
      agent_bank_account_iban: "some content",
      loan_out_company_cert_url: "some content",
      middle_names: "some content",
      agent_bank_account_swift_code: "some content",
      for_paye_only: "some content",
      schedule_d_letter_url: "some content",
      p45_url: "some content",
      agent_bank_sort_code: "some content",
      bank_address: "some content",
      national_insurance_number: "some content",
      passport_issuing_country: "some content",
      agent_bank_address: "some content",
      equipment_rental_url: "some content",
      agent_deal?: true,
      student_loan_repay_direct?: true,
      bank_swift_code: "some content",
      primary_address_country: "some content",
      passport_full_name: "some content",
      agent_tel: "some content",
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
      user_id: 1,
      date_of_birth: %{day: 17, month: 4, year: 2010},
      place_of_birth: "some content",
      screen_credit_name: "some content",
      primary_address_1: "some content",
      primary_address_city: "some content",
      passport_number: "some content",
      passport_url:  "some content",
      agent_address: "some content",
      agent_bank_account_number: "some content",
      agent_bank_account_name: "some content",
      use_loan_out_company?: false
    }

  test "changeset with valid attributes" do
    changeset = Startpack.changeset(%Startpack{}, @valid_attrs)
    assert changeset.valid?
  end



  # ---- validate startpack changeset tests ---- #
  test "box_rental_changeset valid attributes" do
    with_allowances = %{project_id: 1,
      equipment_rental_required?: true,
      box_rental_required?: true,
      box_rental_cap: 200 # should fail as box rental is required
    }
    offer = default_offer(with_allowances)
    changeset = Startpack.box_rental_changeset(%Startpack{}, @valid_box_attrs, offer)
    assert changeset.valid?
  end

  test "box_rental_changeset box not required" do
    with_allowances = %{project_id: 1,
      equipment_rental_required?: false,
      box_rental_required?: false,
      box_rental_cap: nil # should fail as box rental is required
    }
    offer = default_offer(with_allowances)
    struct = Startpack.box_rental_changeset(%Startpack{}, @valid_box_attrs, offer)
    assert Map.has_key?(struct, :box_rental_url)
  end

  test "equipment_rental_changeset valid attributes" do
    with_allowances = %{project_id: 1,
      equipment_rental_required?: true,
      equipment_rental_cap: 200 # should fail as equipment rental is required
    }
    offer = default_offer(with_allowances)
    changeset = Startpack.equipment_rental_changeset(%Startpack{}, @valid_equipment_attrs, offer)
    assert changeset.valid?
  end

  test "equipment_rental_changeset equipment not required" do
    with_allowances = %{project_id: 1,
      equipment_rental_required?: false,
      equipment_rental_cap: nil # should fail as equipment rental is required
    }
    offer = default_offer(with_allowances)
    struct = Startpack.equipment_rental_changeset(%Startpack{}, @valid_equipment_attrs, offer)
    assert Map.has_key?(struct, :equipment_rental_url)
  end

  test "mother_changeset valid attributes" do
    with_allowances = %{project_id: 1,
      box_rental_required?: true,
      equipment_rental_required?: true,
      box_rental_cap: 2000, # should fail as equipment rental is required
      equipment_rental_cap: 2000 # should fail as equipment rental is required
    }
    offer = default_offer(with_allowances)
    changeset = Startpack.mother_changeset(%Startpack{}, @valid_box_equipment_agent_attrs, offer)
    assert changeset.valid?
  end

  test "mother_changeset loan out true" do
    with_allowances = %{project_id: 1,
      box_rental_required?: true,
      equipment_rental_required?: true,
      box_rental_cap: 2000, # should fail as equipment rental is required
      equipment_rental_cap: 2000 # should fail as equipment rental is required
    }
    valid_attrs_loan_out_true = Map.put(@valid_box_equipment_agent_attrs, :use_loan_out_company?, true)
    offer = default_offer(with_allowances)
    changeset = Startpack.mother_changeset(%Startpack{}, valid_attrs_loan_out_true, offer)
    assert changeset.valid?
  end



  # base changeset tests (unconditional required fields)
  test "base changeset for validating startpack with missing basic required data" do
    invalid = %{ @valid_attrs | passport_url: "" }

    changeset = Startpack.base_requirement_changeset(%Startpack{}, invalid)
    refute changeset.valid?
  end
  test "base changeset for validating startpack with valid basic data" do
    changeset = Startpack.base_requirement_changeset(%Startpack{}, @valid_attrs)
    assert changeset.valid?
  end

  # agent changeset tests (conditionally required fields depending on agent deal?)
  test "validating startpack with agent_deal? false and missing required data" do
    valid = %{ @valid_attrs | agent_deal?: false, agent_bank_address: "" }

    changeset = Startpack.agent_requirement_changeset(%Startpack{}, valid)
    # struct should not be converted to a changeset as agent_deal? == false
    # so we dont cast or validate required any fields, just return the struct/changeset
    assert changeset == %Startpack{}
  end
  test "validating startpack with agent_deal? true and missing required data" do
    invalid = %{ @valid_attrs | agent_bank_address: "" }

    changeset = Startpack.agent_requirement_changeset(%Startpack{}, invalid)
    refute changeset.valid?
  end
  test "validating startpack with agent_deal? true and all required data given" do
    changeset = Startpack.agent_requirement_changeset(%Startpack{}, @valid_attrs)
    assert changeset.valid?
  end

  # vehicle allowance changeset tests (conditionally required fields depending on vehicle_allowance_per_week)
  test "validating startpack with no vehicle allowance returns without adding validations" do
    offer = %{vehicle_allowance_per_week: 0}
    valid = %{ @valid_attrs | vehicle_make: "" }
    changeset = Startpack.vehicle_allowance_changeset(%Startpack{}, valid, offer)
    # changeset function will not touch the startpack struct as vehicle allowance is 0
    assert %Startpack{} == changeset
  end
  test "validating startpack with vehicle allowance can validation" do
    offer = %{vehicle_allowance_per_week: 10}
    invalid = %{ @valid_attrs | vehicle_make: "" }
    changeset = Startpack.vehicle_allowance_changeset(%Startpack{}, invalid, offer)
    # changeset is not valid
    refute changeset.valid?
  end
  test "validating startpack with vehicle allowance can pass validation" do
    offer = %{vehicle_allowance_per_week: 10}
    valid = %{ @valid_attrs |
      vehicle_make: "something",
      vehicle_model: "something",
      vehicle_colour: "something",
      vehicle_registration: "something",
      vehicle_insurance_url: "something",
      vehicle_license_url: "something"
    }
    changeset = Startpack.vehicle_allowance_changeset(%Startpack{}, valid, offer)
    # changeset is valid
    assert changeset.valid?
  end

  # contract type validations
  test "validating startpack with contract type PAYE with no errors" do
    offer = %Engine.Offer{contract_type: "PAYE"}
    valid = %{
      p45_url: "url",
      national_insurance_number: "121",
      for_paye_only: "first since april",
      use_loan_out_company?: true
    }
    changeset = Startpack.contract_type_changeset(%Startpack{}, valid, offer)
    assert changeset.valid?
  end

  test "validating startpack with contract type CONSTRUCTION PAYE with no errors" do
    offer = %Engine.Offer{contract_type: "CONSTRUCTION PAYE"}
    valid = %{
      p45_url: "url",
      national_insurance_number: "121",
      for_paye_only: "first since april",
      use_loan_out_company?: true
    }
    changeset = Startpack.contract_type_changeset(%Startpack{}, valid, offer)
    assert changeset.valid?
  end

  test "validating startpack with contract type TRANSPORT PAYE with no errors" do
    offer = %Engine.Offer{contract_type: "TRANSPORT PAYE"}
    valid = %{
      p45_url: "url",
      national_insurance_number: "121",
      for_paye_only: "first since april",
      use_loan_out_company?: true
    }
    changeset = Startpack.contract_type_changeset(%Startpack{}, valid, offer)
    assert changeset.valid?
  end

  test "validating startpack with contract type CONSTRUCTION PAYE with no errors loan out false" do
    offer = %Engine.Offer{contract_type: "CONSTRUCTION PAYE"}
    valid = %{
      p45_url: "url",
      national_insurance_number: "121",
      for_paye_only: "first since april",
      use_loan_out_company?: false
    }
    changeset = Startpack.contract_type_changeset(%Startpack{}, valid, offer)
    assert changeset.valid?
  end

  test "validating startpack with contract type TRANSPORT PAYE with no errors loan out false" do
    offer = %Engine.Offer{contract_type: "TRANSPORT PAYE"}
    valid = %{
      p45_url: "url",
      national_insurance_number: "121",
      for_paye_only: "first since april",
      use_loan_out_company?: false
    }
    changeset = Startpack.contract_type_changeset(%Startpack{}, valid, offer)
    assert changeset.valid?
  end

  test "validating startpack with contract type TRANSPORT SCHEDULE-D with no errors loan out false" do
    offer = %Engine.Offer{contract_type: "TRANSPORT SCHEDULE-D"}
    valid = %{
      p45_url: "url",
      national_insurance_number: "121",
      for_paye_only: "first since april",
      use_loan_out_company?: false,
      schedule_d_letter_url: "url.com"
    }
    changeset = Startpack.contract_type_changeset(%Startpack{}, valid, offer)
    assert changeset.valid?
  end

  test "validating startpack with contract type CONSTRUCTION SCHEDULE-D with no errors loan out false" do
    offer = %Engine.Offer{contract_type: "CONSTRUCTION SCHEDULE-D", daily_or_weekly: "daily"}
    valid = %{
      p45_url: "url",
      national_insurance_number: "121",
      for_paye_only: "first since april",
      use_loan_out_company?: false,
      schedule_d_letter_url: "url.com"
    }
    changeset = Startpack.contract_type_changeset(%Startpack{}, valid, offer)
    assert changeset.valid?
  end

  test "validating startpack with contract type PAYE with errors" do
    offer = %Engine.Offer{contract_type: "PAYE"}
    invalid = %{
      p45_url: "url",
      national_insurance_number: "121",
      for_paye_only: "not in dropdown",
      use_loan_out_company?: false
    }
    changeset = Startpack.contract_type_changeset(%Startpack{}, invalid, offer)
    refute changeset.valid?
  end
  test "validating startpack with contract type SCHEDULE-D with errors" do
    offer = %Engine.Offer{contract_type: "SCHEDULE-D", daily_or_weekly: "daily"}
    invalid = %{ schedule_d_letter_url: "" }
    changeset = Startpack.contract_type_changeset(%Startpack{}, invalid, offer)
    refute changeset.valid?
  end
  test "validating startpack with contract type SCHEDULE-D with no errors" do
    offer = %Engine.Offer{contract_type: "SCHEDULE-D", daily_or_weekly: "daily"}
    valid = %{ schedule_d_letter_url: "url" }
    changeset = Startpack.contract_type_changeset(%Startpack{}, valid, offer)
    assert changeset.valid?
  end
  test "validating startpack adds no validation with contract type SCHEDULE-D but weekly" do
    offer = %Engine.Offer{contract_type: "SCHEDULE-D", daily_or_weekly: "weekly"}
    valid = %{}
    changeset = Startpack.contract_type_changeset(%Startpack{}, valid, offer)
    assert changeset == %Startpack{}
  end

  # Student loan logic:
  test "startpack valid student loan already repaid" do
    valid = %{student_loan_not_repayed?: false}
    changeset = Startpack.student_loan_changeset(%Startpack{}, valid)
    assert changeset.valid?
    assert Map.has_key?(changeset.changes, :student_loan_not_repayed?)
  end
  test "startpack valid - student loan being repaid direct" do
    base = %{
      student_loan_not_repayed?: true,
      student_loan_repay_direct?: true,
      student_loan_finished_before_6_april?: nil
    }

    changeset = Startpack.student_loan_changeset(%Startpack{}, base)
    refute changeset.valid?

    valid = %{ base | student_loan_finished_before_6_april?: true }
    changeset = Startpack.student_loan_changeset(%Startpack{}, valid)
    assert changeset.valid?
    assert Map.has_key?(changeset.changes, :student_loan_finished_before_6_april?)

    valid = %{ base | student_loan_finished_before_6_april?: false }
    changeset = Startpack.student_loan_changeset(%Startpack{}, valid)
    assert changeset.valid?
    assert Map.has_key?(changeset.changes, :student_loan_finished_before_6_april?)
  end
  test "startpack valid - student loan not being repaid direct" do
    base = %{
      student_loan_not_repayed?: true,
      student_loan_repay_direct?: false,
      student_loan_plan_1?: nil,
      student_loan_finished_before_6_april?: nil
    }

    invalid = %{ base | student_loan_repay_direct?: nil }
    changeset = Startpack.student_loan_changeset(%Startpack{}, invalid)
    refute changeset.valid?

    changeset = Startpack.student_loan_changeset(%Startpack{}, base)
    refute changeset.valid?

    invalid1 = %{ base | student_loan_plan_1?: true }
    changeset = Startpack.student_loan_changeset(%Startpack{}, invalid1)
    refute changeset.valid?

    invalid2 = %{ base | student_loan_plan_1?: false }
    changeset = Startpack.student_loan_changeset(%Startpack{}, invalid2)
    refute changeset.valid?

    valid1 = %{ invalid1 | student_loan_finished_before_6_april?: true }
    changeset = Startpack.student_loan_changeset(%Startpack{}, valid1)
    assert changeset.valid?

    valid2 = %{ invalid2 | student_loan_finished_before_6_april?: false }
    changeset = Startpack.student_loan_changeset(%Startpack{}, valid2)
    assert changeset.valid?

  end
end
