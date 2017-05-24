defmodule Karma.Repo.Migrations.CreateStartpack do
  use Ecto.Migration

  def change do
    create table(:startpacks) do
      add :gender, :string
      add :middle_names, :string
      add :aka, :string
      add :screen_credit_name, :string
      add :mobile_tel, :string
      add :emergency_contact_name, :string
      add :emergency_contact_relationship, :string
      add :emergency_contact_tel, :string
      add :date_of_birth, :date
      add :place_of_birth, :string
      add :country_of_legal_nationality, :string
      add :country_of_permanent_residence, :string
      add :passport_number, :string
      add :passport_expiry_date, :date
      add :passport_issuing, :string
      add :country, :string
      add :full_name_as_on_passport, :string
      add :passport_url, :string
      add :primary_address_1, :string
      add :primary_address_2, :string
      add :primary_address_city, :string
      add :primary_address_postcode, :string
      add :primary_address_country, :string
      add :primary_address_tel, :string
      add :agent_deal?, :boolean, default: false, null: false
      add :agent_name, :string
      add :agent_company, :string
      add :agent_address, :text
      add :agent_tel, :string
      add :agent_email_address, :string
      add :agent_bank_name, :string
      add :agent_bank_address, :text
      add :agent_bank_sort_code, :string
      add :agent_bank_account_number, :string
      add :agent_bank_account_name, :string
      add :agent_bank_account_swift_code, :string
      add :agent_bank_account_iban, :string
      add :box_rental_value, :integer
      add :box_rental_url, :string
      add :equipment_rental_value, :integer
      add :equipment_rental_url, :string
      add :vehicle_make, :string
      add :vehicle_model, :string
      add :vehicle_colour, :string
      add :vehicle_registration, :string
      add :vehicle_insurance_url, :string
      add :national_insurance_number, :string
      add :vat_number, :string
      add :p45_url, :string
      add :for_paye_only, :string
      add :student_loan_not_repayed?, :boolean, default: false, null: false
      add :student_loan_repay_direct?, :boolean, default: nil
      add :student_loan_plan_1?, :boolean, default: nil
      add :student_loan_finished_before_6_april?, :boolean, default: nil
      add :schedule_d_letter_url, :string
      add :loan_out_company_registration_number, :string
      add :loan_out_company_address, :text
      add :loan_out_company_cert_url, :string
      add :bank_name, :string
      add :bank_address, :text
      add :bank_account_users_full_name, :string
      add :bank_account_number, :string
      add :bank_sort_code, :string
      add :bank_iban, :string
      add :bank_swift_code, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
    create index(:startpacks, [:user_id])

  end
end
