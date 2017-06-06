defmodule Karma.Merger do
  alias Karma.Repo





  def format(data) do
    Enum.reduce(Map.keys(data), %{}, fn(key, acc) ->
      # prefix is "offer", or "startpack"
      prefix = Atom.to_string(key)

      Map.get(data, key) # offer, startpack, user or project
      |> prefix_keys(prefix) # user_first_name
      |> Map.merge(acc)
    end)
  end

  defp prefix_keys(map, prefix) do
    Enum.reduce(Map.keys(map), %{}, fn(key, acc) ->
      prefixed_key = prefix <> "_" <> Atom.to_string(key)
      val = Map.get(map, key)
      Map.put(acc, prefixed_key, val)
    end)
  end

  def get_data_for_merge(offer) do
    %{user: Map.from_struct(Repo.get(Karma.User, offer.user_id)),
      project: Map.from_struct(Repo.get(Karma.Project, offer.project_id)),
      offer: Map.from_struct(Repo.get(Karma.Offer, offer.id)),
      startpack: Map.from_struct(Repo.get_by(Karma.Startpack, user_id: offer.user_id))
    }
  end
end
