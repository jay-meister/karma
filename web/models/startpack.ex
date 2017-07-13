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
    field :agent_deal?, :boolean, default: true, null: false
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
    field :vehicle_license_url, :string
    field :vehicle_bring_own?, :boolean, default: true, nil: false
    field :national_insurance_number, :string
    field :vat_number, :string
    field :p45_url, :string
    field :for_paye_only, :string
    field :student_loan_not_repayed?, :boolean, default: true, nil: false
    field :student_loan_repay_direct?, :boolean, default: nil
    field :student_loan_plan_1?, :boolean, default: nil
    field :student_loan_finished_before_6_april?, :boolean, default: nil
    field :schedule_d_letter_url, :string
    field :use_loan_out_company?, :boolean, default: true, null: false
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
    # file uploads
    field :passport_image, :any, virtual: true
    field :box_rental_image, :any, virtual: true
    field :equipment_rental_image, :any, virtual: true
    field :vehicle_insurance_image, :any, virtual: true
    field :vehicle_license_image, :any, virtual: true
    field :p45_image, :any, virtual: true
    field :schedule_d_letter_image, :any, virtual: true
    field :loan_out_company_cert_image, :any, virtual: true

    belongs_to :user, Karma.User
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :user_id,
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
      :vehicle_license_url,
      :vehicle_bring_own?,
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
      :bank_swift_code,
      :use_loan_out_company?])
  end

  def base_requirements do
    [ # from startpack
      :date_of_birth,
      :place_of_birth,
      :gender,
      :screen_credit_name,
      :country_of_legal_nationality,
      :country_of_permanent_residence,
      :mobile_tel,
      :primary_address_1,
      :primary_address_city,
      :primary_address_postcode,
      :primary_address_country,
      :passport_number,
      :passport_expiry_date,
      :passport_issuing_country,
      :passport_full_name,
      :passport_url,
      :agent_deal?,
      :student_loan_not_repayed?,
      :emergency_contact_name,
      :emergency_contact_relationship,
      :emergency_contact_tel,
      :bank_name,
      :bank_address,
      :bank_account_users_full_name,
      :bank_account_number,
      :bank_sort_code
    ]
  end

  def agent_requirements do
    [ :agent_name,
      :agent_company,
      :agent_address,
      :agent_tel,
      :agent_email_address,
      :agent_bank_name,
      :agent_bank_address,
      :agent_bank_sort_code,
      :agent_bank_account_number,
      :agent_bank_account_name,
    ]
  end

  def vehicle_allowance_keys do
    [ :vehicle_make,
      :vehicle_model,
      :vehicle_colour,
      :vehicle_registration,
      :vehicle_insurance_url,
      :vehicle_license_url
    ]
  end

  def vehicle_bring_own_keys do
    [ :vehicle_make,
      :vehicle_model,
      :vehicle_colour,
      :vehicle_registration
    ]
  end

  def paye_keys do
    [ :p45_url,
      :national_insurance_number,
      :for_paye_only
    ]
  end

  def for_paye_only do
    ["first since april", "now only job", "have another job"]
  end

  def student_loan_keys do
     [ :student_loan_not_repayed?,
       :student_loan_repay_direct?,
       :student_loan_plan_1?,
       :student_loan_finished_before_6_april?
     ]
  end

  def mother_changeset(struct, startpack, offer) do
    struct
    |> box_rental_changeset(startpack, offer)
    |> equipment_rental_changeset(startpack, offer)
    |> agent_requirement_changeset(startpack)
    |> base_requirement_changeset(startpack)
    |> vehicle_allowance_changeset(startpack, offer)
    |> student_loan_changeset(startpack)
    |> contract_type_changeset(startpack, offer)
    |> loan_out_changeset(startpack)
  end

  def base_requirement_changeset(changeset, startpack) do
    changeset
    |> cast(startpack, base_requirements())
    |> validate_required(base_requirements())
  end

  def box_rental_changeset(struct, startpack, offer) do
    case offer.box_rental_required? do
      true ->
        struct
        |> cast(startpack, [:box_rental_value, :box_rental_url])
        |> validate_required([:box_rental_url, :box_rental_value])
      false ->
        struct
    end
  end

  def equipment_rental_changeset(struct, startpack, offer) do
    case offer.equipment_rental_required? do
      true ->
        struct
        |> cast(startpack, [:equipment_rental_value, :equipment_rental_url])
        |> validate_required([:equipment_rental_url, :equipment_rental_value])
      false ->
        struct
    end
  end

  def agent_requirement_changeset(changeset, startpack) do
    case startpack.agent_deal? do
      true ->
        changeset
        |> cast(startpack, agent_requirements())
        |> validate_required(agent_requirements())
      false ->
        changeset
    end
  end

  def vehicle_allowance_changeset(changeset, startpack, offer) do
    case offer.vehicle_allowance_per_week != 0 do
      true ->
        changeset
        |> cast(startpack, vehicle_allowance_keys())
        |> validate_required(vehicle_allowance_keys())
      false ->
        changeset
    end
  end

  def vehicle_bring_own_changeset(struct, %{"vehicle_bring_own?" => vehicle_bring_own?} = startpack_params) do
    case vehicle_bring_own? do
      "true" ->
        struct
        |> cast(startpack_params, vehicle_bring_own_keys())
        |> validate_required(vehicle_bring_own_keys())
      "false" ->
        struct
        |> cast(startpack_params, vehicle_bring_own_keys())
    end
  end

  def contract_type_changeset(changeset, startpack, offer) do
    case offer do
      %Karma.Offer{contract_type: "PAYE"} ->
        case startpack.use_loan_out_company? do
          true ->
            changeset
            |> cast(startpack, paye_keys())
          false ->
            changeset
            |> cast(startpack, paye_keys())
            |> validate_required(paye_keys())
            |> validate_inclusion(:for_paye_only, for_paye_only())
        end
      %Karma.Offer{contract_type: "CONSTRUCTION PAYE"} ->
        case startpack.use_loan_out_company? do
          true ->
            changeset
            |> cast(startpack, paye_keys())
          false ->
            changeset
            |> cast(startpack, paye_keys())
            |> validate_required(paye_keys())
            |> validate_inclusion(:for_paye_only, for_paye_only())
        end
      %Karma.Offer{contract_type: "TRANSPORT PAYE"} ->
        case startpack.use_loan_out_company? do
          true ->
            changeset
            |> cast(startpack, paye_keys())
          false ->
            changeset
            |> cast(startpack, paye_keys())
            |> validate_required(paye_keys())
            |> validate_inclusion(:for_paye_only, for_paye_only())
        end
      %Karma.Offer{contract_type: "SCHEDULE-D", daily_or_weekly: "daily"} ->
        changeset
        |> cast(startpack, [ :schedule_d_letter_url ])
        |> validate_required([ :schedule_d_letter_url ])
      %Karma.Offer{contract_type: "CONSTRUCTION SCHEDULE-D", daily_or_weekly: "daily"} ->
        changeset
        |> cast(startpack, [ :schedule_d_letter_url ])
        |> validate_required([ :schedule_d_letter_url ])
      %Karma.Offer{contract_type: "TRANSPORT SCHEDULE-D"} ->
        changeset
        |> cast(startpack, [ :schedule_d_letter_url ])
        |> validate_required([ :schedule_d_letter_url ])
      _ ->
        changeset
    end
  end

  def student_loan_changeset(changeset, startpack) do
    st_keys = [
      :student_loan_not_repayed?,
      :student_loan_repay_direct?,
      :student_loan_finished_before_6_april?
    ]

    case startpack do
      # student_loan_not_repayed? cannot be null
      %{student_loan_not_repayed?: false} ->
        changeset
        |> cast(startpack, [:student_loan_not_repayed?])
      %{student_loan_repay_direct?: true} ->
        changeset
        |> cast(startpack, st_keys)
        |> validate_required(st_keys)
      _ ->
        st_keys = st_keys ++ [:student_loan_plan_1?]

        changeset
        |> cast(startpack, st_keys)
        |> validate_required(st_keys)
    end
  end

  def upload_type_validation(struct, params) do
    image_keys = [
      :passport_image,
      :box_rental_image,
      :equipment_rental_image,
      :vehicle_insurance_image,
      :p45_image,
      :schedule_d_letter_image,
      :loan_out_company_cert_image
    ]

    struct
    |> cast(params, image_keys)
    |> validate_upload_type(["image/png", "image/jpeg", "application/pdf"])
  end

  defp validate_upload_type(changeset, permitted) do
    Enum.reduce(Map.keys(changeset.changes), changeset, fn(atom, changeset) ->
      upload = Map.get(changeset.changes, atom)
      case Enum.member?(permitted, upload.content_type) do
        true ->
          changeset
        false ->
          changeset
          |> add_error(atom, ".png .jpg .pdf only")
          |> Map.put(:action, :insert)
      end
     end)
  end

  def loan_out_changeset(struct, startpack) do
    case startpack.use_loan_out_company? do
      true ->
        struct
        |> cast(startpack, [:use_loan_out_company?, :loan_out_company_registration_number, :loan_out_company_address, :loan_out_company_cert_url])
        |> validate_required([:use_loan_out_company?, :loan_out_company_registration_number, :loan_out_company_address, :loan_out_company_cert_url])
      false ->
        struct
    end
  end

  def delete_changeset(struct, startpack) do
    struct
    |> cast(startpack, [
      :box_rental_url,
      :equipment_rental_url,
      :schedule_d_letter_url,
      :passport_url,
      :vehicle_insurance_url,
      :vehicle_license_url,
      :p45_url,
      :loan_out_company_cert_url
      ])
  end
end
