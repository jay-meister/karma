defmodule Karma.ComponentHelpers do
  def component(template, assigns \\ []) do
    Karma.ComponentView.render(template, assigns)
  end

  # def component(template, assigns, do: block) do
  #   Karma.ComponentView.render(template, Keyword.merge(assigns, [do: block]))
  # end
end
