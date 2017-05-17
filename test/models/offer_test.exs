defmodule Karma.OfferTest do
  use Karma.ModelCase

  alias Karma.Offer

  @valid_attrs %{accepted: true, active: true, additional_notes: "some content", box_rental_cap: 42, box_rental_description: "some content", box_rental_fee_per_week: 42, box_rental_start_date: "some content", contract_type: "some content", contractor_details_verified: true, currency: "some content", daily_or_weekly: "some content", department: "some content", equipment_rental_cap: 42, equipment_rental_description: "some content", equipment_rental_fee_per_week: 42, equipment_rental_start_date: "some content", fee_per_day_exc_holiday: 42, fee_per_day_inc_holiday: 42, fee_per_week_exc_holiday: 42, fee_per_week_inc_holiday: 42, holiday_pay_per_day: 42, holiday_pay_per_week: 42, job_title: "some content", other_deal_provisions: "some content", overtime_rate_per_hour: 42, seventh_day_fee: 42, sixth_day_fee: 42, start_date: %{day: 17, month: 4, year: 2010}, target_email: "some content", vehicle_allowance_per_week: 42, working_week: "120.5"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Offer.changeset(%Offer{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Offer.changeset(%Offer{}, @invalid_attrs)
    refute changeset.valid?
  end
end
