defmodule Geofox.Core.Route do
  @moduledoc """
  Route planning functions for the Geofox API.

  This module provides functions for finding public transport routes and individual routes
  (walking, cycling) between locations.
  """

  alias Geofox.Client
  alias Geofox.Types

  @doc """
  Get public transport routes between two locations.

  ## Parameters

    * `client` - The Geofox client
    * `start` - Start location as `t:Types.sd_name/0`
    * `dest` - Destination location as `t:Types.sd_name/0`
    * `time` - Journey time as `t:Types.gti_time/0`
    * `opts` - Optional parameters

  ## Options

    * `:language` - Language code (default: "de")
    * `:version` - API version (default: 1)
    * `:filter_type` - Filter type (default: "NO_FILTER")
    * `:time_is_departure` - Whether time is departure (true) or arrival (false) (default: true)
    * `:with_paths` - Include path coordinates (default: false)
    * `:number_of_schedules` - Number of route alternatives (default: 3)
    * `:realtime` - Realtime mode: "PLANDATA", "REALTIME", "AUTO" (default: "AUTO")
    * `:intermediate_stops` - Include intermediate stops (default: false)
    * `:tariff_details` - Include tariff information (default: false)
    * `:return_reduced` - Return reduced fare information (default: false)
    * `:return_partial_tickets` - Return partial ticket information (default: true)
    * `:via` - Via location for routing
    * `:penalties` - List of penalty configurations
    * `:schedules_before` - Number of earlier schedules (default: 0)
    * `:schedules_after` - Number of later schedules (default: 0)
    * `:coordinate_type` - Coordinate system (default: "EPSG_4326")
    * `:use_bike_and_ride` - Enable bike and ride options (default: false)

  ## Examples

      start = Geofox.station("Hauptbahnhof", "Master:1")
      dest = Geofox.station("Flughafen", "Master:3690")
      time = Geofox.gti_time("2024-01-15", "14:30")

      # Basic route search
      {:ok, routes} = Geofox.Core.Route.get_route(client, start, dest, time)

      # Route search with options
      {:ok, routes} = Geofox.Core.Route.get_route(client, start, dest, time,
        with_paths: true,
        number_of_schedules: 5,
        realtime: "REALTIME",
        tariff_details: true
      )

  """
  @spec get_route(Client.t(), Types.sd_name(), Types.sd_name(), Types.gti_time(), keyword()) ::
          {:ok, map()} | {:error, term()}
  def get_route(client, start, dest, time, opts \\ []) do
    request = %{
      language: Keyword.get(opts, :language, "de"),
      version: Keyword.get(opts, :version, 1),
      filterType: Keyword.get(opts, :filter_type, "NO_FILTER"),
      start: start,
      dest: dest,
      time: time,
      timeIsDeparture: Keyword.get(opts, :time_is_departure, true),
      withPaths: Keyword.get(opts, :with_paths, false),
      numberOfSchedules: Keyword.get(opts, :number_of_schedules, 3),
      realtime: Keyword.get(opts, :realtime, "AUTO"),
      intermediateStops: Keyword.get(opts, :intermediate_stops, false),
      tariffDetails: Keyword.get(opts, :tariff_details, false),
      returnReduced: Keyword.get(opts, :return_reduced, false),
      returnPartialTickets: Keyword.get(opts, :return_partial_tickets, true),
      via: Keyword.get(opts, :via),
      penalties: Keyword.get(opts, :penalties),
      schedulesBefore: Keyword.get(opts, :schedules_before, 0),
      schedulesAfter: Keyword.get(opts, :schedules_after, 0),
      coordinateType: Keyword.get(opts, :coordinate_type, "EPSG_4326"),
      useBikeAndRide: Keyword.get(opts, :use_bike_and_ride, false),
      tariffInfoSelector: Keyword.get(opts, :tariff_info_selector),
      continousSearch: Keyword.get(opts, :continuous_search, false),
      contSearchByServiceId: Keyword.get(opts, :cont_search_by_service_id),
      useStationPosition: Keyword.get(opts, :use_station_position, true),
      forcedStart: Keyword.get(opts, :forced_start),
      forcedDest: Keyword.get(opts, :forced_dest),
      toStartBy: Keyword.get(opts, :to_start_by),
      toDestBy: Keyword.get(opts, :to_dest_by),
      returnContSearchData: Keyword.get(opts, :return_cont_search_data)
    }
    |> filter_nil_values()

    Client.post(client, "/gti/public/getRoute", request)
  end

  @doc """
  Get individual routes (walking, cycling) between multiple start and destination points.

  This function is used for non-public transport routing, such as walking or cycling paths.

  ## Parameters

    * `client` - The Geofox client
    * `starts` - List of start locations as `t:Types.sd_name/0`
    * `dests` - List of destination locations as `t:Types.sd_name/0`
    * `opts` - Optional parameters

  ## Options

    * `:language` - Language code (default: "de")
    * `:version` - API version (default: 1)
    * `:filter_type` - Filter type (default: "NO_FILTER")
    * `:max_length` - Maximum route length in meters
    * `:max_results` - Maximum number of results
    * `:type` - Coordinate type (default: "EPSG_4326")
    * `:service_type` - Service type: "FOOTPATH", "BICYCLE" (default: "FOOTPATH")
    * `:profile` - Routing profile (default: "FOOT_NORMAL")
      - For walking: "FOOT_NORMAL"
      - For cycling: "BICYCLE_NORMAL", "BICYCLE_RACING", "BICYCLE_QUIET_ROADS",
        "BICYCLE_MAIN_ROADS", "BICYCLE_BAD_WEATHER"
    * `:speed` - Speed setting (default: "NORMAL")

  ## Examples

      starts = [Geofox.station("Hauptbahnhof", "Master:1")]
      dests = [Geofox.station("Rathaus", "Master:2")]

      # Walking route
      {:ok, routes} = Geofox.Core.Route.get_individual_route(client, starts, dests)

      # Cycling route
      {:ok, routes} = Geofox.Core.Route.get_individual_route(client, starts, dests,
        service_type: "BICYCLE",
        profile: "BICYCLE_NORMAL",
        max_length: 5000
      )

  """
  @spec get_individual_route(Client.t(), [Types.sd_name()], [Types.sd_name()], keyword()) ::
          {:ok, map()} | {:error, term()}
  def get_individual_route(client, starts, dests, opts \\ []) do
    request = %{
      language: Keyword.get(opts, :language, "de"),
      version: Keyword.get(opts, :version, 1),
      filterType: Keyword.get(opts, :filter_type, "NO_FILTER"),
      starts: starts,
      dests: dests,
      maxLength: Keyword.get(opts, :max_length),
      maxResults: Keyword.get(opts, :max_results),
      type: Keyword.get(opts, :type, "EPSG_4326"),
      serviceType: Keyword.get(opts, :service_type, "FOOTPATH"),
      profile: Keyword.get(opts, :profile, "FOOT_NORMAL"),
      speed: Keyword.get(opts, :speed, "NORMAL")
    }
    |> filter_nil_values()

    Client.post(client, "/gti/public/getIndividualRoute", request)
  end

  # Private helper functions

  defp filter_nil_values(map) do
    map
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
