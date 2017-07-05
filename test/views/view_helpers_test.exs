defmodule Karma.ViewHelpersTest do
  use Karma.ConnCase, async: true

  alias Karma.{ViewHelpers}

  test "format_date" do
    {:ok, date} = Date.new(2000, 1, 1)

    formatted_date = ViewHelpers.format_date(date)
    assert formatted_date == "1/1/2000"
  end

  test "format_holiday_rate" do
    formatted_float_1 = ViewHelpers.format_holiday_rate(0.1077)
    formatted_float_2 = ViewHelpers.format_holiday_rate(0.1207)

    assert formatted_float_1 == "10.77%"
    assert formatted_float_2 == "12.07%"
  end

  test "format_duration" do
    formatted_duration = ViewHelpers.format_duration(12)

    assert formatted_duration == "12 weeks"
  end

  test "format_budget" do
    formatted_budget_low = ViewHelpers.format_budget("low")
    formatted_budget_mid = ViewHelpers.format_budget("mid")
    formatted_budget_big = ViewHelpers.format_budget("big")

    assert formatted_budget_low == "None/Low"
    assert formatted_budget_mid == "Mid"
    assert formatted_budget_big == "Big"
  end

  test "format_type" do
    formatted_feature = ViewHelpers.format_type("feature")
    formatted_television = ViewHelpers.format_type("television")

    assert formatted_feature == "Feature Film"
    assert formatted_television == "Television"
  end

  test "format_label" do
    formatted_address = ViewHelpers.format_label(:company_address_2)

    assert formatted_address == "Company address 2"
  end

  test "get_thumbnail function" do
    url = ViewHelpers.get_thumbnail("aaa.pdf")
    assert url == "/images/file.png"

    url = ViewHelpers.get_thumbnail("aaa")
    assert url == "aaa"
  end

  test "get_thumbnail_style function" do
    class = ViewHelpers.get_thumbnail_style("aaa.pdf")
    assert class == "absolute k-left--05 k-h10 mb3 db k-w3 top--1"

    class = ViewHelpers.get_thumbnail_style("aaa")
    assert class == "h5 mb3 db"
  end

  test "check_loan_out with user" do
    contractor = insert_user(%{email: "test@email.co.uk"})
    pm = insert_user(%{email: "pm@test.co.uk"})
    project = insert_project(pm)
    offer = insert_offer(project, %{user_id: contractor.id})
    update_startpack(contractor, %{use_loan_out_company?: true})
    contract = ViewHelpers.check_loan_out("PAYE", offer.user_id)
    assert contract == "LOAN OUT"
  end
end
