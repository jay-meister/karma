defmodule Karma.DashboardViewTest do
  use Karma.ConnCase, async: true

  alias Karma.DashboardView

  test "get_offers(project, eval)" do
    project = %{
      offers: [
        %{accepted: nil},
        %{accepted: nil},
        %{accepted: true}
      ]
    }
    pending_offers = DashboardView.get_offers(project, nil)

    assert pending_offers == "2"
  end
end
