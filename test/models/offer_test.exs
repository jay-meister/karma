defmodule Engine.OfferTest do
  use Engine.ModelCase

  alias Engine.Offer

  @invalid_attrs default_offer(%{daily_or_weekly: "monthly"})

  test "form validation changeset with valid attributes and with allowances" do
    with_allowances = %{project_id: 1,
      equipment_rental_required?: false,
      box_rental_required?: true,
      box_rental_cap: "42000",
      box_rental_description: "a description",
      box_rental_fee_per_week: "4200",
      box_rental_period: "from 10/01/19 for 3 weeks",
      equipment_rental_cap: nil # should still be valid as equipment rental is not required
    }
    offer = default_offer(with_allowances)
    changeset = Offer.form_validation(%Offer{}, offer)
    assert changeset.valid?
  end


  test "form validation changeset with valid attributes and no allowances" do
    no_allowances = %{project_id: 1, box_rental_required?: false, box_rental_required?: false}
    offer = default_offer(no_allowances)
    changeset = Offer.form_validation(%Offer{}, offer)
    assert changeset.valid?
  end

  test "form validation changeset with invalid attributes due to allowances" do
    with_allowances = %{project_id: 1,
      equipment_rental_required?: false,
      box_rental_required?: true,
      box_rental_cap: nil # should fail as box rental is required
    }
    offer = default_offer(with_allowances)
    changeset = Offer.form_validation(%Offer{}, offer)
    refute changeset.valid?
  end

  test "changeset with no end_date selected" do
    changeset = Offer.changeset(%Offer{}, default_offer(%{project_id: 1, end_date: nil}))
    assert changeset.valid?
  end

  test "changeset with valid attributes" do
    changeset = Offer.changeset(%Offer{}, default_offer(%{project_id: 1}))
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Offer.changeset(%Offer{}, @invalid_attrs)
    refute changeset.valid?
  end
end
