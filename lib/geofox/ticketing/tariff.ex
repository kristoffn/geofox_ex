defmodule Geofox.Ticketing.Tariff do
  @moduledoc """
  Functions for retrieving tariff information, metadata, and zone data from the Geofox API.
  """

  alias Geofox.Client
  alias Geofox.Types

  @doc """
  Calculate tariff information for given schedule elements and journey times.

  ## Parameters

    * `client` - The Geofox client
    * `schedule_elements` - List of schedule elements describing the journey
    * `departure` - Departure time as `t:Types.gti_time/0`
    * `arrival` - Arrival time as `t:Types.gti_time/0`
    * `opts` - Optional parameters

  ## Options

    * `:language` - Language code (default: "de")
    * `:version` - API version (default: 1)
    * `:filter_type` - Filter type (default: "NO_FILTER")
    * `:return_reduced` - Return reduced price information (default: false)
    * `:return_partial_tickets` - Return partial ticket options (default: true)
    * `:tariff_info_selector` - List of tariff info selectors to filter results

  ## Examples

      schedule_elements = [%{
        departureStationId: "Master:1",
        arrivalStationId: "Master:2",
        lineId: "HVV:21001:H"
      }]

      departure = Geofox.gti_time("2024-01-15", "14:30")
      arrival = Geofox.gti_time("2024-01-15", "15:00")

      {:ok, tariff} = Geofox.Ticketing.Tariff.get_tariff(
        client,
        schedule_elements,
        departure,
        arrival
      )

  """
  @spec get_tariff(Client.t(), [map()], Types.gti_time(), Types.gti_time(), keyword()) ::
          {:ok, map()} | {:error, term()}
  def get_tariff(client, schedule_elements, departure, arrival, opts \\ []) do
    request = %{
      language: Keyword.get(opts, :language, "de"),
      version: Keyword.get(opts, :version, 1),
      filterType: Keyword.get(opts, :filter_type, "NO_FILTER"),
      scheduleElements: schedule_elements,
      departure: departure,
      arrival: arrival,
      returnReduced: Keyword.get(opts, :return_reduced, false),
      returnPartialTickets: Keyword.get(opts, :return_partial_tickets, true),
      tariffInfoSelector: Keyword.get(opts, :tariff_info_selector)
    }
    |> filter_nil_values()

    Client.post(client, "/gti/public/getTariff", request)
  end

  @doc """
  Get tariff metadata including zones, counties, tariff kinds and levels.

  Returns information about available tariff zones, counties, tariff kinds (like single tickets,
  season tickets), tariff levels, and their relationships.

  ## Parameters

    * `client` - The Geofox client
    * `opts` - Optional parameters

  ## Options

    * `:language` - Language code (default: "de")
    * `:version` - API version (default: 1)
    * `:filter_type` - Filter type (default: "NO_FILTER")

  ## Examples

      {:ok, metadata} = Geofox.Ticketing.Tariff.tariff_meta_data(client)

      # Access different parts of the metadata
      tariff_zones = metadata["tariffZones"]
      tariff_kinds = metadata["tariffKinds"]
      counties = metadata["tariffCounties"]

  """
  @spec tariff_meta_data(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def tariff_meta_data(client, opts \\ []) do
    request = %{
      language: Keyword.get(opts, :language, "de"),
      version: Keyword.get(opts, :version, 1),
      filterType: Keyword.get(opts, :filter_type, "NO_FILTER")
    }
    |> filter_nil_values()

    Client.post(client, "/gti/public/tariffMetaData", request)
  end

  @doc """
  Get information about neighboring tariff zones.

  Returns a list of tariff zones and their neighboring zones, which is useful for
  calculating cross-zone travel costs and route planning.

  ## Parameters

    * `client` - The Geofox client
    * `opts` - Optional parameters

  ## Options

    * `:language` - Language code (default: "de")
    * `:version` - API version (default: 1)
    * `:filter_type` - Filter type (default: "NO_FILTER")

  ## Examples

      {:ok, neighbours} = Geofox.Ticketing.Tariff.tariff_zone_neighbours(client)

      # Find neighbours of a specific zone
      zone_a_neighbours = Enum.find(neighbours["tariffZones"], fn zone ->
        zone["zone"] == "A"
      end)["neighbours"]

  """
  @spec tariff_zone_neighbours(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def tariff_zone_neighbours(client, opts \\ []) do
    request = %{
      language: Keyword.get(opts, :language, "de"),
      version: Keyword.get(opts, :version, 1),
      filterType: Keyword.get(opts, :filter_type, "NO_FILTER")
    }
    |> filter_nil_values()

    Client.post(client, "/gti/public/tariffZoneNeighbours", request)
  end

  @doc """
  Alias for `tariff_meta_data/2` with a more descriptive name.

  Same functionality as `tariff_meta_data/2` but with a clearer function name
  that better describes what the function returns.
  """
  @spec get_metadata(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def get_metadata(client, opts \\ []) do
    tariff_meta_data(client, opts)
  end

  @doc """
  Alias for `tariff_zone_neighbours/2` with a more descriptive name.

  Same functionality as `tariff_zone_neighbours/2` but with a clearer function name.
  """
  @spec get_zone_neighbours(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def get_zone_neighbours(client, opts \\ []) do
    tariff_zone_neighbours(client, opts)
  end

  # Private helper functions

  defp filter_nil_values(map) do
    map
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
