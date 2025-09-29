# lib/geofox/helpers.ex
defmodule Geofox.Helpers do
  @moduledoc """
  Helper functions for creating Geofox API data structures.
  """

  @doc """
  Create a coordinate structure.

  ## Examples

      iex> Geofox.Helpers.coordinate(53.5511, 9.9937)
      %{"x" => 53.5511, "y" => 9.9937, "type" => "EPSG_4326"}

      iex> Geofox.Helpers.coordinate(53.5511, 9.9937, "EPSG_31467")
      %{"x" => 53.5511, "y" => 9.9937, "type" => "EPSG_31467"}

  """
  @spec coordinate(number(), number(), String.t()) :: map()
  def coordinate(x, y, type \\ "EPSG_4326") do
    %{
      "x" => x,
      "y" => y,
      "type" => type
    }
  end

  @doc """
  Create a bounding box from two coordinates.

  ## Examples

      iex> lower = Geofox.Helpers.coordinate(9.9, 53.5)
      iex> upper = Geofox.Helpers.coordinate(10.1, 53.6)
      iex> Geofox.Helpers.bounding_box(lower, upper)
      %{"lowerLeft" => %{"x" => 9.9, "y" => 53.5, "type" => "EPSG_4326"}, "upperRight" => %{"x" => 10.1, "y" => 53.6, "type" => "EPSG_4326"}}

  """
  @spec bounding_box(map(), map()) :: map()
  def bounding_box(lower_left, upper_right) do
    %{
      "lowerLeft" => lower_left,
      "upperRight" => upper_right
    }
  end

  @doc """
  Create a GTI time structure.

  ## Examples

      iex> Geofox.Helpers.gti_time("2024-01-15", "14:30")
      %{"date" => "2024-01-15", "time" => "14:30"}

  """
  @spec gti_time(String.t(), String.t()) :: map()
  def gti_time(date, time) do
    %{
      "date" => date,
      "time" => time
    }
  end

  @doc """
  Create a GTI time structure from an Elixir DateTime.

  ## Examples

      iex> dt = ~U[2024-01-15 14:30:00Z]
      iex> Geofox.Helpers.gti_time_from_datetime(dt)
      %{"date" => "2024-01-15", "time" => "14:30"}

  """
  @spec gti_time_from_datetime(DateTime.t()) :: map()
  def gti_time_from_datetime(datetime) do
    date = Date.to_string(datetime)
    time = datetime |> DateTime.to_time() |> Time.to_string() |> String.slice(0, 5)

    gti_time(date, time)
  end

  @doc """
  Create a station/location structure.

  ## Examples

      iex> Geofox.Helpers.station("Hauptbahnhof", "Master:1")
      %{"name" => "Hauptbahnhof", "id" => "Master:1", "type" => "STATION"}

      iex> Geofox.Helpers.station("Airport", nil, type: "POI")
      %{"name" => "Airport", "id" => nil, "type" => "POI"}

  """
  @spec station(String.t(), String.t() | nil, keyword()) :: map()
  def station(name, id \\ nil, opts \\ []) do
    %{
      "name" => name,
      "id" => id,
      "type" => Keyword.get(opts, :type, "STATION"),
      "city" => Keyword.get(opts, :city),
      "combinedName" => Keyword.get(opts, :combined_name),
      "globalId" => Keyword.get(opts, :global_id),
      "provider" => Keyword.get(opts, :provider),
      "coordinate" => Keyword.get(opts, :coordinate),
      "layer" => Keyword.get(opts, :layer),
      "tariffDetails" => Keyword.get(opts, :tariff_details),
      "serviceTypes" => Keyword.get(opts, :service_types),
      "hasStationInformation" => Keyword.get(opts, :has_station_information),
      "address" => Keyword.get(opts, :address)
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
