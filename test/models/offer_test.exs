defmodule Karma.OfferTest do
  use Karma.ModelCase

  alias Karma.Offer

  @invalid_attrs default_offer(%{daily_or_weekly: "monthly"})

  test "changeset with valid attributes" do
    changeset = Offer.changeset(%Offer{}, default_offer(%{project_id: 1}))
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Offer.changeset(%Offer{}, @invalid_attrs)
    refute changeset.valid?
  end
end
