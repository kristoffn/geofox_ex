defmodule Geofox.Ticketing.Optimizer do
  @moduledoc """
  Ticket optimization functions for the Geofox API.

  This module provides functions for optimizing ticket selection for individual journeys
  and groups, helping users find the most cost-effective ticket options.
  """

  alias Geofox.Client

  @doc """
  Optimize ticket selection for a single journey or group.

  This function analyzes a given route and passenger composition to recommend
  the most cost-effective ticket options, considering factors like group size,
  return journeys, and available ticket types.

  ## Parameters

    * `client` - The Geofox client
    * `route` - Route information object containing trip details, tariff regions, and timing
    * `opts` - Optional parameters

  ## Options

    * `:language` - Language code (default: "de")
    * `:version` - API version (default: 1)
    * `:filter_type` - Filter type (default: "NO_FILTER")
    * `:with_return_journey` - Include return journey in optimization
    * `:number_of_adults` - Number of adult passengers
    * `:number_of_children` - Number of child passengers
    * `:tickets` - List of existing tickets to consider in optimization

  ## Route Structure

  The route parameter should contain:
  - `trip` - List of trip segments with stations and lines
  - `departure` - Departure time (ISO 8601 format)
  - `arrival` - Arrival time (ISO 8601 format)
  - `tariffRegions` - Tariff zone information
  - `singleTicketTariffLevelId` - Tariff level identifier
  - `extraFareType` - Extra fare requirements ("NO", "POSSIBLE", "REQUIRED")

  ## Examples

      # Basic route structure
      route = %{
        trip: [
          %{
            start: %{id: "Master:1", name: "Hauptbahnhof"},
            destination: %{id: "Master:2", name: "Flughafen"},
            line: %{id: "HVV:S1", name: "S1"},
            vehicleType: "S_BAHN"
          }
        ],
        departure: "2024-01-15T14:30:00+01:00",
        arrival: "2024-01-15T15:15:00+01:00",
        tariffRegions: %{
          zones: [%{regions: ["A", "B"]}]
        },
        singleTicketTariffLevelId: 1,
        extraFareType: "NO"
      }

      # Optimize for a single adult
      {:ok, tickets} = Geofox.Ticketing.Optimizer.single_ticket_optimizer(client, route,
        number_of_adults: 1,
        number_of_children: 0
      )

      # Optimize for a family with return journey
      {:ok, tickets} = Geofox.Ticketing.Optimizer.single_ticket_optimizer(client, route,
        number_of_adults: 2,
        number_of_children: 2,
        with_return_journey: true
      )

  ## Returns

  The response includes:
  - `tickets` - List of optimized ticket recommendations with:
    - Ticket type and pricing information
    - Person type applicability
    - Regional validity
    - Cost comparison data

  """
  @spec single_ticket_optimizer(Client.t(), map(), keyword()) :: {:ok, map()} | {:error, term()}
  def single_ticket_optimizer(client, route, opts \\ []) do
    request = %{
      language: Keyword.get(opts, :language, "de"),
      version: Keyword.get(opts, :version, 1),
      filterType: Keyword.get(opts, :filter_type, "NO_FILTER"),
      withReturnJourney: Keyword.get(opts, :with_return_journey),
      numberOfAdults: Keyword.get(opts, :number_of_adults),
      numberOfChildren: Keyword.get(opts, :number_of_children),
      tickets: Keyword.get(opts, :tickets),
      route: route
    }
    |> filter_nil_values()

    Client.post(client, "/gti/public/singleTicketOptimizer", request)
  end

  # Private helper functions

  defp filter_nil_values(map) do
    map
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
