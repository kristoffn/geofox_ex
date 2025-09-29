defmodule Geofox do
  @moduledoc """
  Public API for interacting with the HVV Geofox API.

  This module provides an interface to all Geofox API functionality including:
  - Route planning and individual routing
  - Station and line information
  - Real-time departures and announcements
  - Tariff calculation and ticket optimization
  - Vehicle tracking and map data
  """

  alias Geofox.Client
  alias Geofox.Helpers
  alias Geofox.Types

  alias Geofox.Core.{Departures, Lines, Route, Session, Stations}
  alias Geofox.Realtime.VehicleMap
  alias Geofox.Services.Announcements
  alias Geofox.Ticketing.{Optimizer, Tariff, Tickets}
  alias Geofox.Utils.Validation

  ## Client Management

  @doc """
  Create a new Geofox client.

  ## Options

    * `:base_url` - Base URL for the API (default: "https://gti.geofox.de")
    * `:timeout` - Request timeout in milliseconds (default: 30000)
    * `:headers` - Additional headers to include in requests
    * `:user` - Username for authentication (if required)
    * `:password` - Password for authentication (if required)

  ## Examples

      iex> client = Geofox.new()
      iex> client = Geofox.new(timeout: 60000)

  """
  @spec new(keyword()) :: Client.t()
  defdelegate new(opts \\ []), to: Client

  ## Helper Functions for Data Structure Creation

  @doc """
  Create a coordinate structure.

  ## Examples

      iex> Geofox.coordinate(53.5511, 9.9937)
      %{"x" => 53.5511, "y" => 9.9937, "type" => "EPSG_4326"}

  """
  @spec coordinate(number(), number(), String.t()) :: map()
  defdelegate coordinate(x, y, type \\ "EPSG_4326"), to: Helpers

  @doc """
  Create a bounding box from two coordinates.
  """
  @spec bounding_box(map(), map()) :: map()
  defdelegate bounding_box(lower_left, upper_right), to: Helpers

  @doc """
  Create a GTI time structure.

  ## Examples

      iex> Geofox.gti_time("2024-01-15", "14:30")
      %{"date" => "2024-01-15", "time" => "14:30"}

  """
  @spec gti_time(String.t(), String.t()) :: map()
  defdelegate gti_time(date, time), to: Helpers

  @doc """
  Create a GTI time structure from an Elixir DateTime.
  """
  @spec gti_time_from_datetime(DateTime.t()) :: map()
  defdelegate gti_time_from_datetime(datetime), to: Helpers

  @doc """
  Create a station/location structure.

  ## Examples

      iex> Geofox.station("Hauptbahnhof", "Master:1")
      %{"name" => "Hauptbahnhof", "id" => "Master:1", "type" => "STATION"}

  """
  @spec station(String.t(), String.t() | nil, keyword()) :: map()
  defdelegate station(name, id \\ nil, opts \\ []), to: Helpers

  ## Core API Functions

  # Session Management
  @doc """
  Initialize a session with the Geofox API to get service information and validate connectivity.
  """
  @spec init(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  defdelegate init(client, opts \\ []), to: Session

  # Route Planning
  @doc """
  Get public transport routes between two locations.

  ## Examples

      start = Geofox.station("Hauptbahnhof", "Master:1")
      dest = Geofox.station("Flughafen", "Master:3690")
      time = Geofox.gti_time("2024-01-15", "14:30")

      {:ok, routes} = Geofox.get_route(client, start, dest, time)

  """
  @spec get_route(Client.t(), Types.sd_name(), Types.sd_name(), Types.gti_time(), keyword()) ::
          {:ok, map()} | {:error, term()}
  defdelegate get_route(client, start, dest, time, opts \\ []), to: Route

  @doc """
  Get individual routes (walking, cycling) between multiple start and destination points.
  """
  @spec get_individual_route(Client.t(), [Types.sd_name()], [Types.sd_name()], keyword()) ::
          {:ok, map()} | {:error, term()}
  defdelegate get_individual_route(client, starts, dests, opts \\ []), to: Route

  # Departures
  @doc """
  Get departure information for a station.

  ## Examples

      station = Geofox.station("Hauptbahnhof", "Master:1")
      time = Geofox.gti_time("2024-01-15", "14:30")

      {:ok, departures} = Geofox.departure_list(client, station, time)

  """
  @spec departure_list(Client.t(), Types.sd_name(), Types.gti_time(), keyword()) ::
          {:ok, map()} | {:error, term()}
  defdelegate departure_list(client, station, time, opts \\ []), to: Departures

  @doc """
  Get the complete course/schedule of a specific departure.
  """
  @spec departure_course(Client.t(), String.t(), Types.sd_name(), String.t(), keyword()) ::
          {:ok, map()} | {:error, term()}
  defdelegate departure_course(client, line_key, station, time, opts \\ []), to: Departures

  # Stations and Lines
  @doc """
  Search for stations, addresses, or points of interest by name.
  """
  @spec check_name(Client.t(), Types.sd_name(), keyword()) ::
          {:ok, map()} | {:error, term()}
  defdelegate check_name(client, name, opts \\ []), to: Stations

  @doc """
  Get detailed information about a station including elevators and accessibility.
  """
  @spec get_station_information(Client.t(), Types.sd_name(), keyword()) ::
          {:ok, map()} | {:error, term()}
  defdelegate get_station_information(client, station, opts \\ []), to: Stations

  @doc """
  List all available stations.
  """
  @spec list_stations(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  defdelegate list_stations(client, opts \\ []), to: Stations

  @doc """
  List all available lines with optional subline information.
  """
  @spec list_lines(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  defdelegate list_lines(client, opts \\ []), to: Lines

  # Tariff and Ticketing
  @doc """
  Calculate tariff information for a given route.
  """
  @spec get_tariff(Client.t(), [map()], Types.gti_time(), Types.gti_time(), keyword()) ::
          {:ok, map()} | {:error, term()}
  defdelegate get_tariff(client, schedule_elements, departure, arrival, opts \\ []), to: Tariff

  @doc """
  Get tariff metadata including available zones, counties, and tariff types.
  """
  @spec tariff_meta_data(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  defdelegate tariff_meta_data(client, opts \\ []), to: Tariff

  @doc """
  Get information about neighboring tariff zones.
  """
  @spec tariff_zone_neighbours(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  defdelegate tariff_zone_neighbours(client, opts \\ []), to: Tariff

  @doc """
  Optimize ticket selection for a single journey.
  """
  @spec single_ticket_optimizer(Client.t(), map(), keyword()) ::
          {:ok, map()} | {:error, term()}
  defdelegate single_ticket_optimizer(client, route, opts \\ []), to: Optimizer

  @doc """
  Get list of available tickets.
  """
  @spec list_tickets(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  defdelegate list_tickets(client, opts \\ []), to: Tickets

  # Real-time and Vehicle Information
  @doc """
  Get vehicle positions and movements within a bounding box.
  """
  @spec get_vehicle_map(Client.t(), Types.bounding_box(), keyword()) ::
          {:ok, map()} | {:error, term()}
  defdelegate get_vehicle_map(client, bounding_box, opts \\ []), to: VehicleMap

  @doc """
  Get track coordinates for specific stop points.
  """
  @spec get_track_coordinates(Client.t(), [String.t()], keyword()) ::
          {:ok, map()} | {:error, term()}
  defdelegate get_track_coordinates(client, stop_point_keys, opts \\ []), to: VehicleMap

  # Services and Announcements
  @doc """
  Get service announcements and disruption information.
  """
  @spec get_announcements(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  defdelegate get_announcements(client, opts \\ []), to: Announcements

  # Validation Utilities
  @doc """
  Check if a postal code is within the HVV service area.
  """
  @spec check_postal_code(Client.t(), integer(), keyword()) :: {:ok, map()} | {:error, term()}
  defdelegate check_postal_code(client, postal_code, opts \\ []), to: Validation
end
