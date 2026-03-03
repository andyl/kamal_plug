defmodule KamalPlug.MixProject do
  use Mix.Project

  def project do
    [
      app: :kamal_plug,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      usage_rules: usage_rules(),
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:prod), do: ["lib/kamal_plug"]
  defp elixirc_paths(_),     do: ["lib"]

  defp deps do
    [
      {:igniter, "~> 0.6", runtime: false, optional: true},
      {:plug, "~> 1.15"},
      {:usage_rules, "~> 1.2", only: :dev, runtime: false},
    ]
  end

  defp usage_rules do
    [
      file: "RULES.md",
      usage_rules: [:igniter]
    ]
  end
end
