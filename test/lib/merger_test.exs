defmodule Karma.MergerTest do
  use Karma.ConnCase
  alias Karma.Merger

  test "get all data for merge" do
    contractor = insert_user(%{email: "contractor@gmail.com"})
    startpack = insert_startpack(%{user_id: contractor.id})
    project = insert_project(contractor)
    offer = insert_offer(project, %{user_id: contractor.id, target_email: contractor.email})
    data = Merger.get_data_for_merge(offer)

    # assert the data map holds the correct user, project, startpack, offer
    assert data.user.email == contractor.email
    assert data.project.name == project.name
    assert data.offer.contract_type == offer.contract_type
    assert data.startpack.gender == startpack.gender
  end

  test "format data with prefixed keys" do
    map = %{offer: %{contract_type: "paye"}, startpack: %{gender: "male"}}
    expected = %{"offer_contract_type" => "paye", "startpack_gender" => "male"}
    formatted = Merger.format(map)
    assert formatted == expected
  end
end
