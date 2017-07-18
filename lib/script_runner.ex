defmodule Engine.ScriptRunner do
  def run_merge_script(args) do
    System.cmd("node", args)
  end
end
