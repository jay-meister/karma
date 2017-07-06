defmodule Karma.Formatter do
  alias Karma.ViewHelpers

  def format_data(data) do
    offer_data = data.offer
    project_data = data.project
    startpack_data = data.startpack
    user_data = data.user

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
      "date_of_birth": ViewHelpers.format_date(startpack_data.date_of_birth)
    }
    startpack_data =
      case offer_data.box_rental_required? do
        true ->
          %{
            startpack_data |
            "box_rental_value": "#{currency_symbol}#{format_number(startpack_data.box_rental_value)}",
            }
        _not_true ->
          startpack_data
      end
    startpack_data =
      case offer_data.equipment_rental_required? do
        true ->
          %{
            startpack_data |
            "equipment_rental_value": "#{currency_symbol}#{format_number(startpack_data.equipment_rental_value)}",
            }
        _not_true ->
          startpack_data
      end


    %{
      offer: offer_data,
      project: project_data,
      startpack: startpack_data,
      user: user_data
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
      "vehicle_allowance_per_week": "#{currency_symbol}#{format_number(offer_data.vehicle_allowance_per_week)}",
      "fee_per_day_inc_holiday": "#{currency_symbol}#{format_number(offer_data.fee_per_day_inc_holiday)}",
      "fee_per_day_exc_holiday": "#{currency_symbol}#{format_number(offer_data.fee_per_day_exc_holiday)}",
      "fee_per_week_inc_holiday": "#{currency_symbol}#{format_number(offer_data.fee_per_week_inc_holiday)}",
      "fee_per_week_exc_holiday": "#{currency_symbol}#{format_number(offer_data.fee_per_week_exc_holiday)}",
      "holiday_pay_per_day": "#{currency_symbol}#{format_number(offer_data.holiday_pay_per_week)}",
      "holiday_pay_per_week": "#{currency_symbol}#{format_number(offer_data.holiday_pay_per_week)}",
      "sixth_day_fee_inc_holiday": "#{currency_symbol}#{format_number(round(offer_data.sixth_day_fee_inc_holiday))}",
      "sixth_day_fee_exc_holiday": "#{currency_symbol}#{format_number(round(offer_data.sixth_day_fee_exc_holiday))}",
      "seventh_day_fee_inc_holiday": "#{currency_symbol}#{format_number(round(offer_data.seventh_day_fee_inc_holiday))}",
      "seventh_day_fee_exc_holiday": "#{currency_symbol}#{format_number(round(offer_data.seventh_day_fee_exc_holiday))}",
      "start_date": ViewHelpers.format_date(offer_data.start_date)
    }
    offer_data =
      case offer_data.box_rental_required? do
        true ->
          %{
            offer_data |
            "box_rental_fee_per_week": "#{currency_symbol}#{format_number(offer_data.box_rental_fee_per_week)}",
            "box_rental_cap": "#{currency_symbol}#{format_number(offer_data.box_rental_cap)}",
          }
        _not_true ->
          offer_data
      end
    offer_data =
      case offer_data.equipment_rental_required? do
        true ->
          %{
            offer_data |
            "equipment_rental_fee_per_week": "#{currency_symbol}#{format_number(offer_data.equipment_rental_fee_per_week)}",
            "equipment_rental_cap": "#{currency_symbol}#{format_number(offer_data.equipment_rental_cap)}",
          }
        _not_true ->
          offer_data
      end
    offer_data
  end

  def format_number(number) do
    number
    |> Integer.to_char_list
    |> Enum.reverse
    |> Enum.chunk(3, 3, [])
    |> Enum.join(",")
    |> String.reverse
  end
end
