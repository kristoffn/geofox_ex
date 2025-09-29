defmodule Geofox.MixProject do
  use Mix.Project

  @source_url "https://github.com/kristoffn/geofox_ex"
  @version "0.1.0"

  def project do
    [
      app: :geofox_ex,
      version: @version,
      elixir: "~> 1.14",
      deps: deps(),
      docs: docs(),
      package: package(),
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        plt_add_apps: [:mix]
      ],
      test_coverage: [tool: ExCoveralls],
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:req, "~> 0.4.0"},
      {:jason, "~> 1.4"},
      {:timex, "~> 3.7"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      {:bypass, "~> 2.1", only: :test},
      {:mox, "~> 1.1", only: :test},
    ]
  end


  defp package do
    [
      description: "Elixir client library for the Hamburg Public Transport (HVV) Geofox API, providing route planning, real-time departures, station information, and tariff calculations.",
      licenses: ["MIT"],
      keywords: ["hvv", "hamburg", "public-transport", "api", "geofox", "transportation"],
      links: %{
        "GitHub" => @source_url,
        "HVV Geofox API" => "https://gti.geofox.de"
      },
      maintainers: ["Kristof Nagy"],
      files: ~w(lib .formatter.exs mix.exs README* LICENSE* CHANGELOG*)
    ]
  end

  defp docs do
    [
      extras: [
        LICENSE: [title: "License"],
        "README.md": [title: "Overview"]
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      formatters: ["html"],
      groups_for_modules: groups_for_modules()
    ]
  end

  defp groups_for_modules do
    [
      "Core API": [
        Geofox.Core.Route,
        Geofox.Core.Departures,
        Geofox.Core.Stations,
        Geofox.Core.Lines,
        Geofox.Core.Session
      ],
      Ticketing: [
        Geofox.Ticketing.Tariff,
        Geofox.Ticketing.Optimizer,
        Geofox.Ticketing.Tickets
      ],
      "Real-time": [
        Geofox.Realtime.VehicleMap,
        Geofox.Realtime.TrackCoordinates
      ],
      Services: [
        Geofox.Services.Announcements
      ],
      Utilities: [
        Geofox.Utils.ErrorHandler,
        Geofox.Utils.Validation,
        Geofox.Helpers,
        Geofox.Types
      ],
      "Low-level": [
        Geofox.Client
      ]
    ]
  end
end
