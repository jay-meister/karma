defmodule Karma.OfferControllerTest do
  use Karma.ConnCase

  alias Karma.Offer
  @valid_attrs %{accepted: true, active: true, additional_notes: "some content", box_rental_cap: 42, box_rental_description: "some content", box_rental_fee_per_week: 42, box_rental_start_date: "some content", contract_type: "some content", contractor_details_verified: true, currency: "some content", daily_or_weekly: "some content", department: "some content", equipment_rental_cap: 42, equipment_rental_description: "some content", equipment_rental_fee_per_week: 42, equipment_rental_start_date: "some content", fee_per_day_exc_holiday: 42, fee_per_day_inc_holiday: 42, fee_per_week_exc_holiday: 42, fee_per_week_inc_holiday: 42, holiday_pay_per_day: 42, holiday_pay_per_week: 42, job_title: "some content", other_deal_provisions: "some content", overtime_rate_per_hour: 42, seventh_day_fee: 42, sixth_day_fee: 42, start_date: %{day: 17, month: 4, year: 2010}, target_email: "some content", vehicle_allowance_per_week: 42, working_week: "120.5"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, offer_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing offers"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, offer_path(conn, :new)
    assert html_response(conn, 200) =~ "New offer"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, offer_path(conn, :create), offer: @valid_attrs
    assert redirected_to(conn) == offer_path(conn, :index)
    assert Repo.get_by(Offer, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, offer_path(conn, :create), offer: @invalid_attrs
    assert html_response(conn, 200) =~ "New offer"
  end

  test "shows chosen resource", %{conn: conn} do
    offer = Repo.insert! %Offer{}
    conn = get conn, offer_path(conn, :show, offer)
    assert html_response(conn, 200) =~ "Show offer"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, offer_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    offer = Repo.insert! %Offer{}
    conn = get conn, offer_path(conn, :edit, offer)
    assert html_response(conn, 200) =~ "Edit offer"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    offer = Repo.insert! %Offer{}
    conn = put conn, offer_path(conn, :update, offer), offer: @valid_attrs
    assert redirected_to(conn) == offer_path(conn, :show, offer)
    assert Repo.get_by(Offer, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    offer = Repo.insert! %Offer{}
    conn = put conn, offer_path(conn, :update, offer), offer: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit offer"
  end

  test "deletes chosen resource", %{conn: conn} do
    offer = Repo.insert! %Offer{}
    conn = delete conn, offer_path(conn, :delete, offer)
    assert redirected_to(conn) == offer_path(conn, :index)
    refute Repo.get(Offer, offer.id)
  end
end
