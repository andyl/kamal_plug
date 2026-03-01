defmodule KamalPlug.MixProject do
  use Mix.Project

  def project do
    [
      app: :kamal_plug,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      usage_rules: usage_rules(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:igniter, "~> 0.6", runtime: false},
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
