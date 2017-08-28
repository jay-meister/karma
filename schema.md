
# Project Schema

- type - **string**
- budget - **string**
- name - **string**
- codename - **string**
- description - **text**
- start_date - **date**
- duration - **integer**
- studio_name - **string**
- company_name - **string**
- company_address_1 - **string**
- company_address_2 - **string**
- company_address_city - **string**
- company_address_postcode - **string**
- company_address_country - **string**
- operating_base_address_1 - **string**
- operating_base_address_2 - **string**
- operating_base_address_city - **string**
- operating_base_address_postcode - **string**
- operating_base_address_country - **string**
- locations - **string**
- holiday_rate - **float**
- additional_notes - **text**
- active - **boolean** default: true, null: false
- user_id - **integer**


# Offers Schema

- recipient_fullname - **string**
- target_email - **string**
- department - **string**
- job_title - **string**
- contract_type - ["SCHEDULE-D", "PAYE"] **string**
- start_date - **date**
- end_date - **date**
- daily_or_weekly - **string**
- working_week - **float**
- currency - **string**
- overtime_rate_per_hour - **integer**
- other_deal_provisions - **text**
- box_rental_description - **text**
- box_rental_fee_per_week - **integer**
- box_rental_cap - **integer**
- box_rental_period - **string**
- equipment_rental_description - **string**
- equipment_rental_fee_per_week - **integer**
- equipment_rental_cap - **integer**
- equipment_rental_period - **string**
- vehicle_allowance_per_week - **integer**
- fee_per_day_inc_holiday - **integer**
- fee_per_day_exc_holiday - **integer**
- fee_per_week_inc_holiday - **integer**
- fee_per_week_exc_holiday - **integer**
- holiday_pay_per_day - **integer**
- holiday_pay_per_week - **integer**
- sixth_day_fee_inc_holiday - **float**
- seventh_day_fee_inc_holiday - **float**
- additional_notes - **text**
- accepted - **boolean**, default: nil
- active - **boolean**, default: true
- contractor_details_accepted - **boolean**, default: nil
- sixth_day_fee_exc_holiday - **float**
- seventh_day_fee_exc_holiday - **float**
- sixth_day_fee_multiplier - **float**
- seventh_day_fee_multiplier - **float**
- box_rental_required - **boolean**
- equipment_rental_required - **boolean**
- project_id - **integer**
- user_id - **integer**

# Startpacks Schema

- gender - **string**
- middle_names - **string**
- aka - **string**
- screen_credit_name - **string**
- mobile_tel - **string**
- emergency_contact_name - **string**
- emergency_contact_relationship - **string**
- emergency_contact_tel - **string**
- date_of_birth - **date**
- place_of_birth - **string**
- country_of_legal_nationality - **string**
- country_of_permanent_residence - **string**
- passport_number - **string**
- passport_expiry_date - **date**
- passport_issuing_country - **string**
- passport_full_name - **string**
- passport_url - **string**
- primary_address_1 - **string**
- primary_address_2 - **string**
- primary_address_city - **string**
- primary_address_postcode - **string**
- primary_address_country - **string**
- primary_address_tel - **string**
- agent_deal?- **boolean**, default: false, null: false
- agent_name - **string**
- agent_company - **string**
- agent_address - **text**
- agent_tel - **string**
- agent_email_address - **string**
- agent_bank_name - **string**
- agent_bank_address - **text**
- agent_bank_sort_code - **string**
- agent_bank_account_number - **string**
- agent_bank_account_name - **string**
- agent_bank_account_swift_code - **string**
- agent_bank_account_iban - **string**
- box_rental_value - **integer**
- box_rental_url - **string**
- equipment_rental_value - **integer**
- equipment_rental_url - **string**
- vehicle_make - **string**
- vehicle_model - **string**
- vehicle_colour - **string**
- vehicle_registration - **string**
- vehicle_insurance_url - **string**
- vehicle_license_url - **string**
- national_insurance_number - **string**
- vat_number - **string**
- p45_url - **string**
- for_paye_only - **string**
- student_loan_not_repayed?- **boolean**, default: false, null: false
- student_loan_repay_direct?- **boolean**, default: nil
- student_loan_plan_1?- **boolean**, default: nil
- student_loan_finished_before_6_april?- **boolean**, default: nil
- schedule_d_letter_url - **string**
- loan_out_company_name - **string**
- loan_out_company_registration_number - **string**
- loan_out_company_address - **string**
- loan_out_company_email - **string**
- loan_out_company_cert_url - **string**
- bank_name - **string**
- bank_address - **text**
- bank_account_users_full_name - **string**
- bank_account_number - **string**
- bank_sort_code - **string**
- bank_iban - **string**
- bank_swift_code - **string**
- user_id - **integer**


# documents
- url - **string**
- category - **string**
- name - **string**
- project_id - **integer**
- offer_id - **integer**

# signees
- name - **string**
- email - **string**
- approver_type - **string**
- role - **string**

# Document Signee
- document_id **integer**
- signee_id **integer**
- order **integer**
