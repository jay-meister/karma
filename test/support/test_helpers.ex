defmodule Karma.TestHelpers do
  alias Karma.{Repo, User, Project, Offer, Startpack,
    Document, Signee, DocumentSignee, AlteredDocument}

  def mother_setup() do
    user = insert_user() # This represents the user that created the project (PM)
    contractor = insert_user(%{email: "cont@gmail.com"})
    project = insert_project(user)
    offer = insert_offer(project)
    document = insert_document(project)
    signee1 = insert_approver(project, %{email: "signee1@gmail.com"})
    signee2 = insert_approver(project, %{email: "signee2@gmail.com"})
    signee3 = insert_approver(project, %{email: "signee3@gmail.com"})
    recipient_1 = insert_approver(project, %{email: "recipient1@gmail.com", approver_type: "Recipient"})
    doc_sign1 = insert_document_approver(document, signee1, %{order: 2})
    doc_sign2 = insert_document_approver(document, signee2, %{order: 3})
    doc_sign3 = insert_document_approver(document, signee3, %{order: 1})
    doc_recip1 = insert_document_approver(document, recipient_1, %{order: 4})
    conn = login_user(Phoenix.ConnTest.build_conn, user)

    {:ok,
      conn: conn,
      user: user,
      project: project,
      offer: offer,
      document: document,
      contractor: contractor,
      signee1: signee1,
      signee2: signee2,
      signee3: signee3,
      doc_sign1: doc_sign1,
      doc_sign2: doc_sign2,
      doc_sign3: doc_sign3,
      doc_recip1: doc_recip1,
      recipient_1: recipient_1
    }
  end

  def insert_user(attrs \\ %{}) do
    changes = Map.merge(default_user(), attrs)

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

  def update_startpack(user, attrs \\ %{}) do
    startpack = Map.merge(default_startpack(), attrs)

    Repo.get_by(Startpack, user_id: user.id)
    |> Startpack.changeset(startpack)
    |> Repo.update!()
  end

  def insert_offer(project, attrs \\ %{}) do
    changes = Map.merge(default_offer(), attrs)

    project
    |> Ecto.build_assoc(:offers, %{})
    |> Offer.changeset(changes)
    |> Repo.insert!
  end

  def insert_document(project, attrs \\ %{}) do
    default_doc = %{ url: "ww.image.co", name: "PAYE", category: "Deal" }
    changes = Map.merge(default_doc, attrs)

    project
    |> Ecto.build_assoc(:documents, %{})
    |> Document.changeset(changes)
    |> Repo.insert!
  end

  def insert_approver(project, attrs \\ %{}) do
    default_signee = %{name: "John Smith", approver_type: "Approver", email: "johnsmith@gmail.com", role: "Producer"}
    changes = Map.merge(default_signee, attrs)

    project
    |> Ecto.build_assoc(:signees, %{})
    |> Signee.changeset(changes)
    |> Repo.insert!
  end

  def insert_document_approver(document, signee, attrs \\ %{}) do
    default_document_signee = %{document_id: document.id, signee_id: signee.id, order: 2}
    changes = Map.merge(default_document_signee, attrs)

    DocumentSignee.changeset(%DocumentSignee{}, changes)
    |> Repo.insert!
  end

  def insert_merged_document(document, offer, attrs \\ %{}) do
    default = %{
      merged_url: "www.aws.com",
      status: "merged"
    }
    changes = Map.merge(default, attrs)

    # add link to original document and offer
    Ecto.build_assoc(offer, :altered_documents, document_id: document.id)
    |> AlteredDocument.merged_changeset(changes)
    |> Repo.insert!()
  end

  def default_user(attrs \\ %{}) do
    default = %{first_name: "Joe",
      last_name: "Blogs",
      email: "test@test.com",
      password: "Password123!",
      terms_accepted: true,
      verified: true,
      startpacks: %{}
    }

    Map.merge(default, attrs)
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
    default = %{
      recipient_fullname: "Full Name",
      active: true,
      additional_notes: "You will be allowed 3 days leave",
      box_rental_required?: true,
      box_rental_cap: "42000.0",
      box_rental_description: "n/a",
      box_rental_fee_per_week: "4200.0",
      box_rental_period: "from 10/01/19 for 3 weeks",
      contract_type: "PAYE",
      contractor_details_accepted: true,
      currency: "gbp",
      daily_or_weekly: "weekly",
      department: "Accounts",
      equipment_rental_required?: true,
      equipment_rental_cap: 0,
      equipment_rental_description: "n/a",
      equipment_rental_fee_per_week: 0,
      equipment_rental_period: "n/a",
      fee_per_day_inc_holiday: "4200.0",
      fee_per_day_exc_holiday: "4200.0",
      fee_per_week_inc_holiday: "10000",
      fee_per_week_exc_holiday: "10000",
      holiday_pay_per_day: 100,
      holiday_pay_per_week: 500,
      job_title: "Cashier",
      other_deal_provisions: "n/a",
      seventh_day_fee_inc_holiday: "100",
      seventh_day_fee_exc_holiday: "100",
      seventh_day_fee_multiplier: "1.0",
      sixth_day_fee_inc_holiday: "100",
      sixth_day_fee_exc_holiday: "100",
      sixth_day_fee_multiplier: "1.0",
      start_date: %{day: 17, month: 4, year: 2019},
      target_email: "a_new_email@gmail.com",
      vehicle_allowance_per_week: "10",
      working_week: "5.5"
    }
    Map.merge(default, attrs)
  end

  def default_startpack(attrs \\ %{}) do
    default = %{
    date_of_birth: %{day: 17, month: 4, year: 2019},
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
    vehicle_bring_own?: false,
    primary_address_country: "some content",
    passport_full_name: "some content",
    agent_tel: "some content",
    vehicle_insurance_url: "some content",
    student_loan_finished_before_6_april?: true,
    agent_company: "some content",
    primary_address_2: "some content",
    use_loan_out_company?: "false",
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
    Map.merge(default, attrs)
  end
end
