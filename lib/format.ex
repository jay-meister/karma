defmodule Engine.Formatter do
  alias Engine.ViewHelpers

  def format_data(data) do
    offer_data = data.offer
    project_data = data.project
    startpack_data = data.startpack
    user_data = data.user
    offer_custom_field_data = data.offer_custom_field
    project_custom_field_data = data.project_custom_field

    currency_symbol =
      case offer_data.currency do
        "gbp" -> "£"
        "eur" -> "€"
        "usd" -> "$"
      end

    # format offer data
    offer_data = format_offer_data(offer_data)

    # format project data
    project_data = %{
      project_data |
      "holiday_rate": ViewHelpers.format_holiday_rate(project_data.holiday_rate),
      "start_date": ViewHelpers.format_date(project_data.start_date)
    }

    # format startpack data
    startpack_data = %{
      startpack_data |
      "date_of_birth": ViewHelpers.format_date(startpack_data.date_of_birth),
      "passport_expiry_date": ViewHelpers.format_date(startpack_data.passport_expiry_date)
    }
    startpack_data =
      case offer_data.box_rental_required? do
        true ->
          %{
            startpack_data |
            "box_rental_value": "#{currency_symbol} #{format_number(startpack_data.box_rental_value)}",
            }
        _not_true ->
          startpack_data
      end
    startpack_data =
      case offer_data.equipment_rental_required? do
        true ->
          %{
            startpack_data |
            "equipment_rental_value": "#{currency_symbol} #{format_number(startpack_data.equipment_rental_value)}",
            }
        _not_true ->
          startpack_data
      end
    startpack_data =
      case startpack_data.agent_deal? do
        true -> startpack_data
        false ->
          startpack_data
          |> Map.delete("agent_company")
          |> Map.delete("agent_address")
          |> Map.delete("agent_tel")
          |> Map.delete("agent_email_address")
          |> Map.delete("agent_bank_name")
          |> Map.delete("agent_bank_address")
          |> Map.delete("agent_bank_sort_code")
          |> Map.delete("agent_bank_account_number")
          |> Map.delete("agent_bank_account_name")
          |> Map.delete("agent_bank_account_swift_code")
          |> Map.delete("agent_bank_account_iban")
      end
    startpack_data =
      case startpack_data.use_loan_out_company? do
        true -> startpack_data
        false ->
          startpack_data
          |> Map.delete("loan_out_company_name")
          |> Map.delete("loan_out_company_registration_number")
          |> Map.delete("loan_out_company_address")
          |> Map.delete("loan_out_company_email")
          |> Map.delete("loan_out_company_cert_url")
      end

    %{
      offer: offer_data,
      project: project_data,
      startpack: startpack_data,
      user: user_data,
      offer_custom_field: offer_custom_field_data,
      project_custom_field: project_custom_field_data
    }
  end

  def format_offer_data(offer_data) do
    currency_symbol =
      case offer_data.currency do
        "gbp" -> "£"
        "eur" -> "€"
        "usd" -> "$"
      end

    # format offer data
    offer_data = %{
      offer_data |
      "vehicle_allowance_per_week": "#{currency_symbol} #{format_number(offer_data.vehicle_allowance_per_week)}",
      "fee_per_day_inc_holiday": "#{currency_symbol} #{format_number(offer_data.fee_per_day_inc_holiday)}",
      "fee_per_day_exc_holiday": "#{currency_symbol} #{format_number(offer_data.fee_per_day_exc_holiday)}",
      "fee_per_week_inc_holiday": "#{currency_symbol} #{format_number(offer_data.fee_per_week_inc_holiday)}",
      "fee_per_week_exc_holiday": "#{currency_symbol} #{format_number(offer_data.fee_per_week_exc_holiday)}",
      "holiday_pay_per_day": "#{currency_symbol} #{format_number(offer_data.holiday_pay_per_day)}",
      "holiday_pay_per_week": "#{currency_symbol} #{format_number(offer_data.holiday_pay_per_week)}",
      "sixth_day_fee_inc_holiday": "#{currency_symbol} #{format_number(offer_data.sixth_day_fee_inc_holiday)}",
      "sixth_day_fee_exc_holiday": "#{currency_symbol} #{format_number(offer_data.sixth_day_fee_exc_holiday)}",
      "sixth_day_holiday_pay": "#{currency_symbol} #{format_number(offer_data.sixth_day_holiday_pay)}",
      "seventh_day_fee_inc_holiday": "#{currency_symbol} #{format_number(offer_data.seventh_day_fee_inc_holiday)}",
      "seventh_day_fee_exc_holiday": "#{currency_symbol} #{format_number(offer_data.seventh_day_fee_exc_holiday)}",
      "seventh_day_holiday_pay": "#{currency_symbol} #{format_number(offer_data.seventh_day_holiday_pay)}",
      "end_date": ViewHelpers.format_date(offer_data.end_date),
      "start_date": ViewHelpers.format_date(offer_data.start_date),
      "currency": String.upcase(offer_data.currency),
      "daily_or_weekly": String.capitalize(offer_data.daily_or_weekly),
      "updated_at": ViewHelpers.format_date(offer_data.updated_at)
    }

    offer_data =
      case offer_data.box_rental_required? do
        true ->
          %{
            offer_data |
            "box_rental_fee_per_week": "#{currency_symbol} #{format_number(offer_data.box_rental_fee_per_week)}",
            "box_rental_cap": "#{currency_symbol} #{format_number(offer_data.box_rental_cap)}",
          }
        _not_true ->
          offer_data
      end
    offer_data =
      case offer_data.equipment_rental_required? do
        true ->
          %{
            offer_data |
            "equipment_rental_fee_per_week": "#{currency_symbol} #{format_number(offer_data.equipment_rental_fee_per_week)}",
            "equipment_rental_cap": "#{currency_symbol} #{format_number(offer_data.equipment_rental_cap)}",
          }
        _not_true ->
          offer_data
      end
    offer_data
  end

  def format_number(number) do
    number = number / 1
    :erlang.float_to_binary(number, [decimals: 2])
  end
end
