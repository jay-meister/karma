defmodule Engine.Merger do
  alias Engine.{Repo, Formatter}

  def merge_multiple(_offer, []) do
    {:ok, "Documents merged"}
  end

  def merge_multiple(offer, documents) do
    [document | tail] = documents
    case merge(offer, document) do
      {:ok, url} ->

        Ecto.build_assoc(offer, :altered_documents, document_id: document.id)
        |> Engine.AlteredDocument.merged_changeset(%{merged_url: url})
        |> Repo.insert()

        merge_multiple(offer, tail)
      {:error, error} -> {:error, error}
    end
  end

  def merge(offer, document) do
    # download document

    file_name = get_file_name(document.url)
    case Engine.S3.download(document.url, System.cwd() <> "/tmp/" <> file_name) do
      {:error, _error} ->
        {:error, "There was an error retrieving the document"}
      {:ok, doc_path} ->
        # get formatted data
        json =
          get_data_for_merge(offer)
          |> Formatter.format_data()
          |> format()
          |> Poison.encode!()

        # do merge
        merged_path = get_merged_path(doc_path, offer, document)
        case wrap_merge_script(json, doc_path, merged_path) do
          {:error, _error} ->
            {:error, "There was an error creating the document"}
          {:ok, merged_path} ->
            # save to S3
            # get file name from merged path
            image_params = %{path: merged_path, filename: get_file_name(merged_path)}
            case Engine.S3.upload({:url, image_params, offer.project.codename, String.replace(document.name, " ", "_")}) do
              {:error, _url, _error} ->
                {:error, "There was an error saving the document"}
              {:ok, :url, url} ->
                {:ok, url}
            end
        end
      end
  end
  def get_file_name(path) do
    path |> String.split("/") |> Enum.reverse() |> hd()
  end
  def get_merged_path(unmerged_path, offer, document) do
    identifier =
      "-" <> Integer.to_string(offer.id) <>
      "-" <> Integer.to_string(offer.user_id) <>
      "-" <> Integer.to_string(document.id) <>
      ".pdf"

    String.replace_suffix(unmerged_path, ".pdf", identifier)
    # returns unmerged_path1-4-5.pdf
  end

  def wrap_merge_script(json, doc_path, merged_path) do
    res = Engine.ScriptRunner.run_merge_script(["merge.js", json, doc_path, merged_path])

    case res do
      {path, 0} -> {:ok, path}
      {error, 1} -> {:error, error}
    end
  end

  def get_data_for_merge(offer) do
    first_name = Map.take(Map.from_struct(Repo.get(Engine.User, offer.user_id)), [:first_name])
    last_name = Map.take(Map.from_struct(Repo.get(Engine.User, offer.user_id)), [:last_name])
    full_name = "#{first_name.first_name} #{last_name.last_name}"
    offer = Repo.get(Engine.Offer, offer.id) |> Repo.preload(:custom_fields)
    custom_fields = Enum.map(offer.custom_fields, fn custom_field -> Map.from_struct(custom_field) end)

    offer_custom_fields = build_custom_field_map(%{}, custom_fields)
    project = Map.from_struct(Repo.get(Engine.Project, offer.project_id) |> Repo.preload(:custom_fields))
    project_custom_field_structs = project.custom_fields |> Enum.filter(fn field -> field.type == "Project" end)
    project_custom_fields = build_custom_field_map(%{}, Enum.map(project_custom_field_structs, fn custom_field -> Map.from_struct(custom_field) end))
    %{user: Map.merge(Map.take(Map.from_struct(Repo.get(Engine.User, offer.user_id)), user()), %{full_name: full_name}),
      project: Map.take(Map.from_struct(Repo.get(Engine.Project, offer.project_id)), project()),
      offer: Map.take(Map.from_struct(Repo.get(Engine.Offer, offer.id)), offer()),
      startpack: Map.take(Map.from_struct(Repo.get_by(Engine.Startpack, user_id: offer.user_id)), startpack()),
      offer_custom_field: offer_custom_fields,
      project_custom_field: project_custom_fields
    }
  end

  def build_custom_field_map(map, []), do: map

  def build_custom_field_map(map, list) do
    [head | tail] = list
    name = String.replace(String.downcase(head.name), " ", "_")
    name =
      case String.last(name) == "_" do
        true -> String.trim_trailing(name, "_")
        false -> name
      end
    name = String.to_atom(name)
    updated_map = Map.put_new(map, name, head.value)
    build_custom_field_map(updated_map, tail)
  end

  # formats nested map of all data, prefixes and flattens
  def format(data) do

    Enum.reduce(Map.keys(data), %{}, fn(key, acc) ->
      # prefix is "offer", or "startpack"
      prefix = Atom.to_string(key)
      Map.get(data, key) # offer, startpack, user or project
      |> prefix_keys(prefix) # user_first_name
      |> Map.merge(acc)
    end)
  end

  # helper used by format function
  defp prefix_keys(map, prefix) do
    Enum.reduce(Map.keys(map), %{}, fn(key, acc) ->
      prefixed_key = prefix <> "_" <> Atom.to_string(key)
      val = Map.get(map, key)
      # replace nulls with empty string as nulls seem to break merge
      val = if val == nil, do: "", else: val
      Map.put(acc, prefixed_key, val)
    end)
  end

  def project do
    [:type,
    :budget,
    :name,
    :codename,
    :description,
    :start_date,
    :duration,
    :studio_name,
    :company_name,
    :company_address_1,
    :company_address_2,
    :company_address_city,
    :company_address_postcode,
    :company_address_country,
    :operating_base_address_1,
    :operating_base_address_2,
    :operating_base_address_city,
    :operating_base_address_postcode,
    :operating_base_address_country,
    :locations,
    :holiday_rate,
    :additional_notes,
    :active
  ]
  end
  def offer do
    [
      :target_email,
      :department,
      :job_title,
      :contract_type,
      :start_date,
      :end_date,
      :daily_or_weekly,
      :working_week,
      :currency,
      :other_deal_provisions,
      :box_rental_required?,
      :box_rental_description,
      :box_rental_fee_per_week,
      :box_rental_cap,
      :box_rental_period,
      :equipment_rental_required?,
      :equipment_rental_description,
      :equipment_rental_fee_per_week,
      :equipment_rental_cap,
      :equipment_rental_period,
      :vehicle_allowance_per_week,
      :fee_per_day_inc_holiday,
      :fee_per_day_exc_holiday,
      :fee_per_week_inc_holiday,
      :fee_per_week_exc_holiday,
      :holiday_pay_per_day,
      :holiday_pay_per_week,
      :sixth_day_fee_inc_holiday,
      :sixth_day_fee_exc_holiday,
      :sixth_day_fee_multiplier,
      :sixth_day_holiday_pay,
      :seventh_day_fee_inc_holiday,
      :seventh_day_fee_exc_holiday,
      :seventh_day_fee_multiplier,
      :seventh_day_holiday_pay,
      :additional_notes,
      :accepted,
      :active,
      :contractor_details_accepted,
      :updated_at
    ]
  end
  def user do
    [
      :email,
      :first_name,
      :last_name
    ]
  end
  def startpack do
    [:gender,
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
    :loan_out_company_name,
    :loan_out_company_registration_number,
    :loan_out_company_address,
    :loan_out_company_email,
    :loan_out_company_cert_url,
    :bank_name,
    :bank_address,
    :bank_account_users_full_name,
    :bank_account_number,
    :bank_sort_code,
    :bank_iban,
    :bank_swift_code]
  end
end
