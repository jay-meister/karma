defmodule Engine.ComponentHelpers do
  def component(template, assigns \\ []) do
    Engine.ComponentView.render(template, assigns)
  end

  # def component(template, assigns, do: block) do
  #   Engine.ComponentView.render(template, Keyword.merge(assigns, [do: block]))
  # end
end
