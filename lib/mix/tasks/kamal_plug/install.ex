defmodule Mix.Tasks.KamalPlug.Install do
  use Mix.Task

  @shortdoc "Adds KamalPlug.HealthCheck to your Phoenix endpoint"

  def run(_argv) do
    script_path = :code.priv_dir(:kamal_plug) |> Path.join("install.exs")
    Mix.shell().cmd("elixir #{script_path}")
  end
end
