defmodule Engine.DashboardViewTest do
  use Engine.ConnCase, async: true

  alias Engine.ViewHelpers

  test "get_offers(project, eval)" do
    project = %{
      offers: [
        %{accepted: nil},
        %{accepted: nil},
        %{accepted: true}
      ]
    }
    pending_offers = ViewHelpers.get_offers(project, nil)

    assert pending_offers == "2"
  end
end
