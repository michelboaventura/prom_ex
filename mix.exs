defmodule PromEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :prom_ex,
      version: "1.11.0",
      elixir: "~> 1.14",
      name: "PromEx",
      source_url: "https://github.com/akoutmos/prom_ex",
      homepage_url: "https://hex.pm/packages/prom_ex",
      description: "Prometheus metrics and Grafana dashboards for all of your favorite Elixir libraries",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.github": :test
      ],
      dialyzer: [
        plt_add_apps: [
          :absinthe,
          :broadway,
          :ecto,
          :mix,
          :oban,
          :phoenix,
          :plug,
          :telemetry_metrics,
          :telemetry_metrics_prometheus_core
        ],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],
      package: package(),
      deps: deps(),
      docs: docs(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Required dependencies
      {:jason, "~> 1.4", optional: true},
      {:finch, "~> 0.18"},
      {:telemetry, ">= 1.0.0"},
      {:telemetry_poller, "~> 1.1"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_metrics_prometheus_core, "~> 1.2"},
      {:peep, "~> 3.0"},
      {:octo_fetch, "~> 0.4"},

      # Optional dependencies depending on what telemetry events the user is interested in capturing
      {:phoenix, ">= 1.7.0", optional: true},
      {:phoenix_live_view, ">= 0.20.0", optional: true},
      {:plug, ">= 1.16.0", optional: true},
      {:plug_cowboy, ">= 2.6.0", optional: true},
      {:ecto, ">= 3.11.0", optional: true},
      {:oban, ">= 2.10.0", optional: true},
      {:absinthe, ">= 1.7.0", optional: true},
      {:broadway, ">= 1.1.0", optional: true},

      # PromEx development related dependencies
      {:bypass, "~> 2.1", only: :test},
      {:ex_doc, "~> 0.34.2", only: :dev},
      {:excoveralls, "~> 0.18.2", only: :test, runtime: false},
      {:doctor, "~> 0.21.0", only: :dev},
      {:credo, "~> 1.7.7", only: :dev},
      {:dialyxir, "~> 1.4.3", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "master",
      logo: "guides/images/logo.svg",
      extras: [
        "README.md",
        "guides/howtos/Writing PromEx Plugins.md",
        "guides/howtos/Telemetry.md",
        "guides/howtos/Running Multiple Agents.md",
        "guides/howtos/Seeding Metrics.md",
        "guides/gallery/All.md"
      ],
      groups_for_extras: [
        "How-To's": ~r/guides\/howtos\/.?/,
        Grafana: ~r/guides\/gallery\/.?/
      ]
    ]
  end

  defp package do
    [
      name: "prom_ex",
      files: ~w(lib priv/grafana_agent priv/*.eex mix.exs README.md LICENSE CHANGELOG.md),
      licenses: ["MIT"],
      maintainers: ["Alex Koutmos"],
      links: %{
        "GitHub" => "https://github.com/akoutmos/prom_ex",
        "Sponsor" => "https://github.com/sponsors/akoutmos"
      }
    ]
  end

  defp aliases do
    [
      docs: [&massage_readme/1, "docs", &copy_files/1],
      test: ["test --exclude mix_task:true"]
    ]
  end

  defp copy_files(_) do
    # Set up directory structure
    File.mkdir_p!("./doc/guides/images")

    # Copy over image files
    "./guides/images/"
    |> File.ls!()
    |> Enum.each(fn image_file ->
      File.cp!("./guides/images/#{image_file}", "./doc/guides/images/#{image_file}")
    end)

    # Clean up previous file massaging
    File.rm!("./README.md")
    File.rename!("./README.md.orig", "./README.md")
  end

  defp massage_readme(_) do
    hex_docs_friendly_header_content = """
    <br>
    <img align="center" width="33%" src="guides/images/logo.svg" alt="PromEx Logo" style="margin-left:33%">
    <img align="center" width="70%" src="guides/images/logo_text.png" alt="PromEx Logo" style="margin-left:15%">
    <br>
    <div align="center">Prometheus metrics and Grafana dashboards for all of your favorite Elixir libraries</div>
    <br>
    --------------------

    [![Hex.pm](https://img.shields.io/hexpm/v/prom_ex?style=for-the-badge)](http://hex.pm/packages/prom_ex)
    [![Build Status](https://img.shields.io/github/actions/workflow/status/akoutmos/prom_ex/main.yml?label=Build%20Status&style=for-the-badge&branch=master)](https://github.com/akoutmos/prom_ex/actions)
    [![Coverage Status](https://img.shields.io/coveralls/github/akoutmos/prom_ex/master?style=for-the-badge)](https://coveralls.io/github/akoutmos/prom_ex?branch=master)
    [![Elixir Slack Channel](https://img.shields.io/badge/slack-%23prom__ex-orange.svg?style=for-the-badge&logo=slack)](https://elixir-lang.slack.com/archives/C01NZ0FBFSR)
    [![Support PromEx](https://img.shields.io/badge/Support%20PromEx-%E2%9D%A4-lightblue?style=for-the-badge)](https://github.com/sponsors/akoutmos)
    """

    File.cp!("./README.md", "./README.md.orig")

    readme_contents = File.read!("./README.md")

    massaged_readme =
      Regex.replace(
        ~r/<!--START-->(.|\n)*<!--END-->/,
        readme_contents,
        hex_docs_friendly_header_content
      )

    File.write!("./README.md", massaged_readme)
  end
end
