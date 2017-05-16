defmodule Karma.ComponentHelpersTest do
  use Karma.ConnCase, async: true

  alias Karma.ComponentHelpers

  test "component(template, assigns)" do
    component = Phoenix.HTML.safe_to_string(ComponentHelpers.component("submit_button.html", title: "Test"))
    assert component =~ "Test"
  end
end
