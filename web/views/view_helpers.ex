defmodule Karma.ViewHelpers do

  alias Karma.{User, Repo}

  def check_loan_out(contract, user_id) do
    case Repo.get(User, user_id) do
      nil ->
        contract
      user ->
        loaded_user = user |> Repo.preload(:startpacks)
        case loaded_user.startpacks.use_loan_out_company? do
          true ->
            "LOAN OUT"
          false ->
            contract
        end
    end
  end

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

  def get_thumbnail(url) do
    case String.ends_with?(url, ".pdf") do
      true -> "/images/pdf.svg"
      false -> url
    end
  end

  def get_thumbnail_style(url) do
    case String.ends_with?(url, ".pdf") do
      true -> "absolute k-left--05 h5 mb3 db w4 k-top--4"
      false -> "h5 mb3 db"
    end
  end

end
