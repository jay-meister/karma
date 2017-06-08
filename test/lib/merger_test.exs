defmodule Karma.MergerTest do
  use Karma.ConnCase
  alias Karma.Merger

  import Mock

  @data %{
    project_name: "Mission Impossible 12: The Fourth Reich Hits Back (3rd Edition)",
    user_full_name: "jackjackjack jackjackjackjackjack",
    user_address_1: "21 dependencies avenue,\nAilsbury Estate,\n3rd ward",
    user_address_2: "London\nN2 5RT\nUnited Kingdom",
    user_email: "jmonies_is_not@somelonghotmail.com.uk"
  }

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



  test "get merged path" do
    result = Merger.get_merged_path("path.pdf", %{id: 1, user_id: 2}, %{id: 3})
    expected = "path-1-2-3.pdf"
    assert result == expected
  end

  test "merge document script success" do
    with_mock Karma.ScriptRunner, [run_merge_script: fn(_) -> {"destination.pdf", 0} end] do
      doc_path = System.cwd() <> "/test/fixtures/fillable.pdf"

      res = Merger.wrap_merge_script(Poison.encode!(@data), doc_path, "destination.pdf")
      assert {:ok, "destination.pdf"} = res
    end
  end

  test "merge document script - no file" do
    with_mock Karma.ScriptRunner, [run_merge_script: fn(_) -> {"some error", 1} end] do
      doc_path = System.cwd() <> "/x/no-file.pdf"
      error_res = Merger.wrap_merge_script(Poison.encode!(@data), doc_path, "destination.pdf")
      assert {:error, _} = error_res
    end
  end
end
