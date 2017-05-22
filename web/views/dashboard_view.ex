defmodule Karma.DashboardView do
  use Karma.Web, :view

  def get_offers(project, eval) do
    Integer.to_string(length(Enum.filter(project.offers, fn(offer) -> offer.accepted == eval end)))
  end


end
