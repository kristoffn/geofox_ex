defmodule Geofox.Core.Departures do
  @moduledoc """
  Functions for retrieving departure information and departure courses from the Geofox API.
  """

  alias Geofox.Client
  alias Geofox.Types

  @doc """
  Get departure list for a station at a specific time.

  ## Parameters

    * `client` - The Geofox client
    * `station` - Station information as `t:Types.sd_name/0`
    * `time` - Departure time as `t:Types.gti_time/0`
    * `opts` - Optional parameters

  ## Options

    * `:language` - Language code (default: "de")
    * `:version` - API version (default: 1)
    * `:filter_type` - Filter type (default: "NO_FILTER")
    * `:stations` - List of stations to query (alternative to single station)
    * `:max_list` - Maximum number of departures to return
    * `:max_time_offset` - Maximum time offset in minutes (default: 120)
    * `:all_stations_in_changing_node` - Include all stations in changing node (default: true)
    * `:use_realtime` - Use realtime data (default: false)
    * `:return_filters` - Return available filters (default: false)
    * `:filter` - List of filter entries to apply
    * `:service_types` - List of service types to include
    * `:departure` - Whether to show departures (default: true)
    * `:coordinate_type` - Coordinate system to use (default: "EPSG_4326")

  ## Examples

      station = Geofox.station("Hauptbahnhof", "Master:1")
      time = Geofox.gti_time("2024-01-15", "14:30")

      {:ok, departures} = Geofox.Core.Departures.departure_list(client, station, time)

      # With options
      {:ok, departures} = Geofox.Core.Departures.departure_list(client, station, time,
        max_list: 20,
        use_realtime: true,
        service_types: ["U_BAHN", "S_BAHN"]
      )

  """
  @spec departure_list(Client.t(), Types.sd_name(), Types.gti_time(), keyword()) ::
          {:ok, map()} | {:error, term()}
  def departure_list(client, station, time, opts \\ []) do
    request = build_departure_list_request(station, time, opts)
    Client.post(client, "/gti/public/departureList", request)
  end

  @doc """
  Get departure list for multiple stations at a specific time.

  Similar to `departure_list/4` but accepts a list of stations instead of a single station.

  ## Examples

      stations = [
        Geofox.station("Hauptbahnhof", "Master:1"),
        Geofox.station("Dammtor", "Master:2")
      ]
      time = Geofox.gti_time("2024-01-15", "14:30")

      {:ok, departures} = Geofox.Core.Departures.departure_list_multi(client, stations, time)

  """
  @spec departure_list_multi(Client.t(), [Types.sd_name()], Types.gti_time(), keyword()) ::
          {:ok, map()} | {:error, term()}
  def departure_list_multi(client, stations, time, opts \\ []) do
    request = build_departure_list_request(nil, time, Keyword.put(opts, :stations, stations))
    Client.post(client, "/gti/public/departureList", request)
  end

  @doc """
  Get the complete course/schedule of a specific departure.

  ## Parameters

    * `client` - The Geofox client
    * `line_key` - Unique identifier for the line
    * `station` - Station information as `t:Types.sd_name/0`
    * `time` - Departure time as ISO 8601 datetime string
    * `opts` - Optional parameters

  ## Options

    * `:language` - Language code (default: "de")
    * `:version` - API version (default: 1)
    * `:filter_type` - Filter type (default: "NO_FILTER")
    * `:direction` - Direction of travel
    * `:origin` - Origin station name
    * `:service_id` - Service ID (default: -1)
    * `:segments` - Which segments to show: "BEFORE", "AFTER", "ALL" (default: "ALL")
    * `:show_path` - Include path coordinates (default: false)
    * `:coordinate_type` - Coordinate system (default: "EPSG_4326")

  ## Examples

      station = Geofox.station("Hauptbahnhof", "Master:1")

      {:ok, course} = Geofox.Core.Departures.departure_course(
        client,
        "HVV:21001:H",
        station,
        "2024-01-15T14:30:00"
      )

  """
  @spec departure_course(Client.t(), String.t(), Types.sd_name(), String.t(), keyword()) ::
          {:ok, map()} | {:error, term()}
  def departure_course(client, line_key, station, time, opts \\ []) do
    request = %{
      language: Keyword.get(opts, :language, "de"),
      version: Keyword.get(opts, :version, 1),
      filterType: Keyword.get(opts, :filter_type, "NO_FILTER"),
      lineKey: line_key,
      station: station,
      time: time,
      direction: Keyword.get(opts, :direction),
      origin: Keyword.get(opts, :origin),
      serviceId: Keyword.get(opts, :service_id, -1),
      segments: Keyword.get(opts, :segments, "ALL"),
      showPath: Keyword.get(opts, :show_path, false),
      coordinateType: Keyword.get(opts, :coordinate_type, "EPSG_4326")
    }
    |> filter_nil_values()

    Client.post(client, "/gti/public/departureCourse", request)
  end

  # Private helper functions

  defp build_departure_list_request(station, time, opts) do
    base_request = %{
      language: Keyword.get(opts, :language, "de"),
      version: Keyword.get(opts, :version, 1),
      filterType: Keyword.get(opts, :filter_type, "NO_FILTER"),
      time: time,
      maxList: Keyword.get(opts, :max_list),
      maxTimeOffset: Keyword.get(opts, :max_time_offset, 120),
      allStationsInChangingNode: Keyword.get(opts, :all_stations_in_changing_node, true),
      useRealtime: Keyword.get(opts, :use_realtime, false),
      returnFilters: Keyword.get(opts, :return_filters, false),
      filter: Keyword.get(opts, :filter),
      serviceTypes: Keyword.get(opts, :service_types),
      departure: Keyword.get(opts, :departure, true),
      coordinateType: Keyword.get(opts, :coordinate_type, "EPSG_4326")
    }

    # Add either station or stations based on what was provided
    request_with_location =
      case {station, Keyword.get(opts, :stations)} do
        {nil, stations} when is_list(stations) -> Map.put(base_request, :stations, stations)
        {station, _} when not is_nil(station) -> Map.put(base_request, :station, station)
        _ -> base_request
      end

    filter_nil_values(request_with_location)
  end

  defp filter_nil_values(map) do
    map
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
