defmodule Geofox.Core.Stations do
  @moduledoc """
  Station related functions for the Geofox API.

  This module provides functions for finding stations, addresses, and points of interest,
  as well as retrieving detailed station information including accessibility features.
  """

  alias Geofox.Client
  alias Geofox.Types

  @doc """
  Search for stations, addresses, or points of interest by name.

  This function searches the system for locations that match the given name or partial name.
  It can find stations, addresses, POIs, and other searchable locations.

  ## Parameters

    * `client` - The Geofox client
    * `name` - Location information as `t:Types.sd_name/0` containing at least a name
    * `opts` - Optional parameters

  ## Options

    * `:language` - Language code (default: "de")
    * `:version` - API version (default: 1)
    * `:filter_type` - Filter type (default: "NO_FILTER")
    * `:max_list` - Maximum number of results to return
    * `:max_distance` - Maximum distance for location searches in meters
    * `:coordinate_type` - Coordinate system (default: "EPSG_4326")
    * `:tariff_details` - Include tariff zone information (default: false)
    * `:allow_type_switch` - Allow switching between location types (default: true)

  ## Examples

      # Search for a station by name
      name_info = %{name: "Hauptbahnhof", type: "STATION"}
      {:ok, results} = Geofox.Core.Stations.check_name(client, name_info)

      # Search with options
      {:ok, results} = Geofox.Core.Stations.check_name(client, name_info,
        max_list: 10,
        tariff_details: true
      )

      # Search for addresses
      address_info = %{name: "Mönckebergstraße 7", type: "ADDRESS"}
      {:ok, results} = Geofox.Core.Stations.check_name(client, address_info)

  """
  @spec check_name(Client.t(), Types.sd_name(), keyword()) :: {:ok, map()} | {:error, term()}
  def check_name(client, name, opts \\ []) do
    request = %{
      language: Keyword.get(opts, :language, "de"),
      version: Keyword.get(opts, :version, 1),
      filterType: Keyword.get(opts, :filter_type, "NO_FILTER"),
      theName: name,
      maxList: Keyword.get(opts, :max_list),
      maxDistance: Keyword.get(opts, :max_distance),
      coordinateType: Keyword.get(opts, :coordinate_type, "EPSG_4326"),
      tariffDetails: Keyword.get(opts, :tariff_details, false),
      allowTypeSwitch: Keyword.get(opts, :allow_type_switch, true)
    }
    |> filter_nil_values()

    Client.post(client, "/gti/public/checkName", request)
  end

  @doc """
  Get detailed information about a station including elevators and accessibility features.

  This function retrieves information about a station, including:
  - Elevator status and specifications
  - Platform layouts and accessibility
  - Real-time elevator status updates

  ## Parameters

    * `client` - The Geofox client
    * `station` - Station information as `t:Types.sd_name/0`
    * `opts` - Optional parameters

  ## Options

    * `:language` - Language code (default: "de")
    * `:version` - API version (default: 1)
    * `:filter_type` - Filter type (default: "NO_FILTER")

  ## Examples

      station = %{
        id: "Master:1",
        name: "Hauptbahnhof",
        type: "STATION"
      }

      {:ok, info} = Geofox.Core.Stations.get_station_information(client, station)

      # Access elevator information
      partial_stations = info["partialStations"]
      elevators = Enum.flat_map(partial_stations, & &1["elevators"])

  ## Returns

  The response includes:
  - `partialStations` - List of station parts with their elevators and features
  - `lastUpdate` - Timestamp of the last information update
  - Elevator details including dimensions, status, and accessibility features

  """
  @spec get_station_information(Client.t(), Types.sd_name(), keyword()) :: {:ok, map()} | {:error, term()}
  def get_station_information(client, station, opts \\ []) do
    request = %{
      language: Keyword.get(opts, :language, "de"),
      version: Keyword.get(opts, :version, 1),
      filterType: Keyword.get(opts, :filter_type, "NO_FILTER"),
      station: station
    }
    |> filter_nil_values()

    Client.post(client, "/gti/public/getStationInformation", request)
  end

  @doc """
  List all available stations.

  This function retrieves a list of all stations in the system,
  optionally filtered by modification types and data release versions.

  ## Parameters

    * `client` - The Geofox client
    * `opts` - Optional parameters

  ## Options

    * `:language` - Language code (default: "de")
    * `:version` - API version (default: 1)
    * `:filter_type` - Filter type (default: "NO_FILTER")
    * `:data_release_id` - Data release ID to filter changes since a specific version
    * `:modification_types` - List of modification types (e.g., ["MAIN", "POSITION"])
    * `:coordinate_type` - Coordinate system (default: "EPSG_4326")
    * `:filter_equivalent` - Filter equivalent stations (default: false)

  ## Examples

      # Get all stations
      {:ok, stations} = Geofox.Core.Stations.list_stations(client)

      # Get stations modified since a specific data release
      {:ok, stations} = Geofox.Core.Stations.list_stations(client,
        data_release_id: "2024-01-15",
        modification_types: ["MAIN", "POSITION"]
      )

  """
  @spec list_stations(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def list_stations(client, opts \\ []) do
    request = %{
      language: Keyword.get(opts, :language, "de"),
      version: Keyword.get(opts, :version, 1),
      filterType: Keyword.get(opts, :filter_type, "NO_FILTER"),
      dataReleaseID: Keyword.get(opts, :data_release_id),
      modificationTypes: Keyword.get(opts, :modification_types),
      coordinateType: Keyword.get(opts, :coordinate_type, "EPSG_4326"),
      filterEquivalent: Keyword.get(opts, :filter_equivalent, false)
    }
    |> filter_nil_values()

    Client.post(client, "/gti/public/listStations", request)
  end

  # Private helper functions

  defp filter_nil_values(map) do
    map
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
