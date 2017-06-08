defmodule Karma.Merger do
  alias Karma.Repo

  # def merge(offer, document) do
  #   # download document
  #   {:ok, doc_path} = S3.download(document.url, System.cwd())
  #
  #   # get formatted data
  #   json = get_data_for_merge(offer) |> format() |> Poison.encode!()
  #
  #   # do merge
  #   merged_path = get_merged_path(doc_path, offer, document)
  #   {:ok, merged_path} = wrap_merge_script(json, doc_path, merged_path)
  #
  #
  #   # save to S3
  #   # get file name from merged path
  #   image_params = %{path: merged_path, filename: "test-1-2-3.pdf"}
  #   {:ok, :url, url} = S3.upload({:url, image_params})
  #
  #   # add merged url to document's table
  #   # add foreign key offer_id to the document table
  #   # add this url to the document table
  # end

  def get_merged_path(unmerged_path, offer, document) do
    identifier =
      "-" <> Integer.to_string(offer.id) <>
      "-" <> Integer.to_string(offer.user_id) <>
      "-" <> Integer.to_string(document.id) <>
      ".pdf"

    String.replace_suffix(unmerged_path, ".pdf", identifier)
    # redurns unmerged_path1-4-5.pdf
  end

  def wrap_merge_script(json, doc_path, merged_path) do
    res = Karma.ScriptRunner.run_merge_script(["merge.js", json, doc_path, merged_path])

    case res do
      {path, 0} -> {:ok, path}
      {error, 1} -> {:error, error}
    end
  end

  # formats nested map of all data, prefixes and flattens
  def format(data) do
    Enum.reduce(Map.keys(data), %{}, fn(key, acc) ->
      # prefix is "offer", or "startpack"
      prefix = Atom.to_string(key)

      Map.get(data, key) # offer, startpack, user or project
      |> prefix_keys(prefix) # user_first_name
      |> Map.merge(acc)
    end)
  end

  # helper used by format function
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
