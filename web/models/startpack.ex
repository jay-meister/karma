defmodule Karma.Startpack do
  use Karma.Web, :model

  schema "startpacks" do
    field :gender, :string
    field :middle_names, :string
    field :aka, :string
    field :screen_credit_name, :string
    field :mobile_tel, :string
    field :emergency_contact_name, :string
    field :emergency_contact_relationship, :string
    field :emergency_contact_tel, :string
    field :date_of_birth, Ecto.Date
    field :place_of_birth, :string
    field :country_of_legal_nationality, :string
    field :country_of_permanent_residence, :string
    field :passport_number, :string
    field :passport_expiry_date, Ecto.Date
    field :passport_issuing_country, :string
    field :passport_full_name, :string
    field :passport_url, :string
    field :primary_address_1, :string
    field :primary_address_2, :string
    field :primary_address_city, :string
    field :primary_address_postcode, :string
    field :primary_address_country, :string
    field :primary_address_tel, :string
    field :agent_deal?, :boolean, default: false
    field :agent_name, :string
    field :agent_company, :string
    field :agent_address, :string
    field :agent_tel, :string
    field :agent_email_address, :string
    field :agent_bank_name, :string
    field :agent_bank_address, :string
    field :agent_bank_sort_code, :string
    field :agent_bank_account_number, :string
    field :agent_bank_account_name, :string
    field :agent_bank_account_swift_code, :string
    field :agent_bank_account_iban, :string
    field :box_rental_value, :integer
    field :box_rental_url, :string
    field :equipment_rental_value, :integer
    field :equipment_rental_url, :string
    field :vehicle_make, :string
    field :vehicle_model, :string
    field :vehicle_colour, :string
    field :vehicle_registration, :string
    field :vehicle_insurance_url, :string
    field :national_insurance_number, :string
    field :vat_number, :string
    field :p45_url, :string
    field :for_paye_only, :string
    field :student_loan_not_repayed?, :boolean, default: false
    field :student_loan_repay_direct?, :boolean, default: nil
    field :student_loan_plan_1?, :boolean, default: nil
    field :student_loan_finished_before_6_april?, :boolean, default: nil
    field :schedule_d_letter_url, :string
    field :loan_out_company_registration_number, :string
    field :loan_out_company_address, :string
    field :loan_out_company_cert_url, :string
    field :bank_name, :string
    field :bank_address, :string
    field :bank_account_users_full_name, :string
    field :bank_account_number, :string
    field :bank_sort_code, :string
    field :bank_iban, :string
    field :bank_swift_code, :string
    belongs_to :user, Karma.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :gender,
      :middle_names,
      :aka,
      :screen_credit_name,
      :mobile_tel,
      :emergency_contact_name,
      :emergency_contact_relationship,
      :emergency_contact_tel,
      :date_of_birth,
      :place_of_birth,
      :country_of_legal_nationality,
      :country_of_permanent_residence,
      :passport_number,
      :passport_expiry_date,
      :passport_issuing_country,
      :passport_full_name,
      :passport_url,
      :primary_address_1,
      :primary_address_2,
      :primary_address_city,
      :primary_address_postcode,
      :primary_address_country,
      :primary_address_tel,
      :agent_deal?,
      :agent_name,
      :agent_company,
      :agent_address,
      :agent_tel,
      :agent_email_address,
      :agent_bank_name,
      :agent_bank_address,
      :agent_bank_sort_code,
      :agent_bank_account_number,
      :agent_bank_account_name,
      :agent_bank_account_swift_code,
      :agent_bank_account_iban,
      :box_rental_value,
      :box_rental_url,
      :equipment_rental_value,
      :equipment_rental_url,
      :vehicle_make,
      :vehicle_model,
      :vehicle_colour,
      :vehicle_registration,
      :vehicle_insurance_url,
      :national_insurance_number,
      :vat_number,
      :p45_url,
      :for_paye_only,
      :student_loan_not_repayed?,
      :student_loan_repay_direct?,
      :student_loan_plan_1?,
      :student_loan_finished_before_6_april?,
      :schedule_d_letter_url,
      :loan_out_company_registration_number,
      :loan_out_company_address,
      :loan_out_company_cert_url,
      :bank_name,
      :bank_address,
      :bank_account_users_full_name,
      :bank_account_number,
      :bank_sort_code,
      :bank_iban,
      :bank_swift_code])
    |> validate_required([:gender])
  end
end
