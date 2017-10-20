defmodule Engine.ViewHelpers do

  alias Engine.{User, Repo, Project}

  def check_loan_out(contract, user_id, offer) do
    project_id = offer.project_id
    project = Repo.get(Project, project_id) |> Repo.preload(:user) |> Repo.preload(:documents)
    project_documents = Enum.map(project.documents, fn document -> document.name end)

    construction_loan_out = Enum.member?(project_documents, "CONSTRUCTION LOAN OUT")
    daily_construction_loan_out = offer.daily_or_weekly == "daily" && Enum.member?(project_documents, "DAILY CONSTRUCTION LOAN OUT")
    daily_transport_loan_out = offer.daily_or_weekly == "daily" && Enum.member?(project_documents, "DAILY TRANSPORT LOAN OUT")
    transport_loan_out = Enum.member?(project_documents, "TRANSPORT LOAN OUT")
    daily = offer.daily_or_weekly == "daily"

    case user_id == nil do
      true ->
        contract
      false ->
        user = Repo.get(User, user_id)
        loaded_user = user |> Repo.preload(:startpacks)
        case loaded_user.startpacks.use_loan_out_company? do
          true ->
            case offer do
              %{department: "Construction"} ->
                case daily_construction_loan_out do
                  true -> "DAILY CONSTRUCTION LOAN OUT"
                  false ->
                    case construction_loan_out do
                      true -> "CONSTRUCTION LOAN OUT"
                      false -> "LOAN OUT"
                    end
                end
              %{department: "Transport"} ->
                case daily_transport_loan_out do
                  true -> "DAILY TRANSPORT LOAN OUT"
                  false ->
                    case transport_loan_out do
                      true -> "TRANSPORT LOAN OUT"
                      false -> "LOAN OUT"
                    end
                end
              _else ->
                case daily do
                  true -> "DAILY LOAN OUT"
                  false -> "LOAN OUT"
                end
            end
          false ->
            contract
        end
    end
  end

  def get_offers(project, eval) do
    Integer.to_string(length(Enum.filter(project.offers, fn(offer) -> offer.accepted == eval end)))
  end

  def format_date(date) do
    case date do
      nil -> "n/a"
      _ ->
        day = Integer.to_string(date.day)
        month = Integer.to_string(date.month)
        year = Integer.to_string(date.year)

        day <> "/" <> month <> "/" <> year
    end
  end

  def format_long_date(date) do
    case date do
      nil -> "n/a"
      _ ->
        day = Integer.to_string(date.day)
        month = find_month(date.month)
        year = Integer.to_string(date.year)
        hour = Integer.to_string(date.hour + 1)
        minutes = String.slice("0" <> Integer.to_string(date.minute), -2, 2)

        "#{day} #{month} #{year}, #{hour}:#{minutes}"
    end
  end

  def find_month(index) do
    case index do
      1 -> "Jan"
      2 -> "Feb"
      3 -> "Mar"
      4 -> "Apr"
      5 -> "May"
      6 -> "Jun"
      7 -> "Jul"
      8 -> "Aug"
      9 -> "Sep"
      10 -> "Oct"
      11 -> "Nov"
      12 -> "Dec"
    end
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
    int_string = Float.to_string(integer)

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
      true -> "/images/file.png"
      false -> url
    end
  end

  def get_thumbnail_style(url) do
    case String.ends_with?(url, ".pdf") do
      true -> "absolute k-left--05 k-h10 mb3 db k-w3 top--1"
      false -> "h5 mb3 db"
    end
  end

  def sort_offers(offers) do
    offers
    |> Enum.sort(&(&1.updated_at >= &2.updated_at))
  end

  def format_working_days(days) do
    case days do
      5.0 -> "5 days"
      5.5 -> "5.5 days"
      6.0 -> "6 days"
    end
  end
end
