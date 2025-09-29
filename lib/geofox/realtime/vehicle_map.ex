defmodule Geofox.Realtime.VehicleMap do
  @moduledoc """
  Real-time vehicle tracking and map data functions for the Geofox API.

  This module provides functions for retrieving real-time vehicle positions and
  track coordinate information within specified geographical areas.
  """

  alias Geofox.Client
  alias Geofox.Types

  @doc """
  Get vehicle positions and movements within a bounding box.

  This function retrieves real-time information about vehicles (buses, trains, etc.)
  within a specified geographical area, including their current positions and movement data.

  ## Parameters

    * `client` - The Geofox client
    * `bounding_box` - Geographical area as `t:Types.bounding_box/0`
    * `opts` - Optional parameters

  ## Options

    * `:language` - Language code (default: "de")
    * `:version` - API version (default: 1)
    * `:filter_type` - Filter type (default: "NO_FILTER")
    * `:period_begin` - Start time for vehicle data (Unix timestamp)
    * `:period_end` - End time for vehicle data (Unix timestamp)
    * `:without_coords` - Exclude coordinate data (default: false)
    * `:coordinate_type` - Coordinate system (default: "EPSG_4326")
    * `:vehicle_types` - List of vehicle types to include (e.g., ["U_BAHN", "S_BAHN", "BUS"])
    * `:realtime` - Include real-time data (default: true)

  ## Examples

      # Create a bounding box around Hamburg city center
      lower_left = Geofox.coordinate(9.9, 53.5)
      upper_right = Geofox.coordinate(10.1, 53.6)
      bbox = Geofox.bounding_box(lower_left, upper_right)

      # Get all vehicles in the area
      {:ok, vehicles} = Geofox.Realtime.VehicleMap.get_vehicle_map(client, bbox)

      # Get only buses and trains with real-time data
      {:ok, vehicles} = Geofox.Realtime.VehicleMap.get_vehicle_map(client, bbox,
        vehicle_types: ["BUS", "U_BAHN", "S_BAHN"],
        realtime: true
      )

  ## Returns

  The response includes:
  - `journeys` - List of vehicle journeys with position and route information
  - Each journey contains segments with coordinates, timing, and real-time delays

  """
  @spec get_vehicle_map(Client.t(), Types.bounding_box(), keyword()) :: {:ok, map()} | {:error, term()}
  def get_vehicle_map(client, bounding_box, opts \\ []) do
    request = %{
      language: Keyword.get(opts, :language, "de"),
      version: Keyword.get(opts, :version, 1),
      filterType: Keyword.get(opts, :filter_type, "NO_FILTER"),
      boundingBox: bounding_box,
      periodBegin: Keyword.get(opts, :period_begin),
      periodEnd: Keyword.get(opts, :period_end),
      withoutCoords: Keyword.get(opts, :without_coords),
      coordinateType: Keyword.get(opts, :coordinate_type, "EPSG_4326"),
      vehicleTypes: Keyword.get(opts, :vehicle_types),
      realtime: Keyword.get(opts, :realtime)
    }
    |> filter_nil_values()

    Client.post(client, "/gti/public/getVehicleMap", request)
  end

  @doc """
  Get track coordinates for specific stop points.

  This function retrieves the geographical track/route coordinates for specific
  stop points or route segments, useful for drawing routes on maps.

  ## Parameters

    * `client` - The Geofox client
    * `stop_point_keys` - List of stop point identifiers
    * `opts` - Optional parameters

  ## Options

    * `:language` - Language code (default: "de")
    * `:version` - API version (default: 1)
    * `:filter_type` - Filter type (default: "NO_FILTER")
    * `:coordinate_type` - Coordinate system (default: "EPSG_4326")

  ## Examples

      # Get track coordinates for specific stop points
      stop_points = ["stopPoint123", "stopPoint456"]
      {:ok, tracks} = Geofox.Realtime.VehicleMap.get_track_coordinates(client, stop_points)

      # Use different coordinate system
      {:ok, tracks} = Geofox.Realtime.VehicleMap.get_track_coordinates(client, stop_points,
        coordinate_type: "EPSG_31467"
      )

  ## Returns

  The response includes:
  - `trackIDs` - List of track identifiers
  - `tracks` - Coordinate data for each track segment
  - Track coordinates can be used to draw route lines on maps

  """
  @spec get_track_coordinates(Client.t(), [String.t()], keyword()) :: {:ok, map()} | {:error, term()}
  def get_track_coordinates(client, stop_point_keys, opts \\ []) do
    request = %{
      language: Keyword.get(opts, :language, "de"),
      version: Keyword.get(opts, :version, 1),
      filterType: Keyword.get(opts, :filter_type, "NO_FILTER"),
      coordinateType: Keyword.get(opts, :coordinate_type, "EPSG_4326"),
      stopPointKeys: stop_point_keys
    }
    |> filter_nil_values()

    Client.post(client, "/gti/public/getTrackCoordinates", request)
  end

  # Private helper functions

  defp filter_nil_values(map) do
    map
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
