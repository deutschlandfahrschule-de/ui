defmodule DfsUi.MixProject do
  use Mix.Project

  @version "0.1.1"
  @source_url "https://github.com/deutschlandfahrschule-de/ui"

  def project do
    [
      app: :dfs_ui,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description:
        "Gemeinsame Oberflächen-Bausteine der Deutschlandfahrschule (HEEx, Tailwind v4)",
      package: [
        files: ~w(lib priv assets package.json mix.exs README.md CHANGELOG.md),
        licenses: ["Proprietary"],
        links: %{"GitHub" => @source_url}
      ],
      docs: [main: "readme", extras: ["README.md"]]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:phoenix, "~> 1.7"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_view, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:lazy_html, ">= 0.1.0", only: :test}
    ]
  end
end
