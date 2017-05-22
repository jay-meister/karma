defmodule Karma.ViewHelpers do

  def get_offers(project, eval) do
    Integer.to_string(length(Enum.filter(project.offers, fn(offer) -> offer.accepted == eval end)))
  end

  def format_date(date) do
    day = Integer.to_string(date.day)
    month = Integer.to_string(date.month)
    year = Integer.to_string(date.year)

    day <> "/" <> month <> "/" <> year
  end

  def format_holiday_rate(float) do
    float_string =
      case float do
        0.1077 -> "10.77%"
        0.1207 -> "12.07%"
      end

    float_string
  end

  def format_duration(integer) do
    int_string = Integer.to_string(integer)

    "#{int_string} weeks"
  end

  def format_budget(string) do
    budget_string =
      case string do
        "low" -> "None/Low"
        "mid" -> "Mid"
        "big" -> "Big"
      end

    budget_string
  end

  def format_type(type) do
    case type do
      "feature" -> "Feature Film"
      "television" -> "Television"
    end
  end

  def format_label(atom) do
    atom
    |> Atom.to_string()
    |> String.replace("_", " ")
    |> String.capitalize()
  end
end
