defmodule Karma.DashboardViewTest do
  use Karma.ConnCase, async: true

  alias Karma.ViewHelpers

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
