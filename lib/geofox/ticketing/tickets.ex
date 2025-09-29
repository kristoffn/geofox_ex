defmodule Geofox.Ticketing.Tickets do
  @moduledoc """
  Functions for ticket listing and management from the Geofox API.

  This module provides functions for retrieving available ticket types,
  their pricing, validity periods, and applicable passenger categories.
  """

  alias Geofox.Client

  @doc """
  Get list of available tickets for a station or general use.

  This function retrieves information about available tickets
  including pricing, validity periods, passenger types, and regional applicability.

  ## Parameters

    * `client` - The Geofox client
    * `opts` - Optional parameters

  ## Options

    * `:language` - Language code (default: "de")
    * `:version` - API version (default: 1)
    * `:filter_type` - Filter type (default: "NO_FILTER")
    * `:station_key` - Station identifier to get station-specific tickets

  ## Examples

      # Get all available tickets
      {:ok, tickets} = Geofox.Ticketing.Tickets.list_tickets(client)

      # Get tickets available at a specific station
      {:ok, tickets} = Geofox.Ticketing.Tickets.list_tickets(client,
        station_key: "Master:1"
      )

  ## Returns

  The response includes:
  - `ticketInfos` - List of ticket information with:
    - Tariff kind and level details
    - Valid regions and zones
    - Person type applicability (adult, child, student, etc.)
    - Validity periods and time restrictions
    - Available variants with pricing
    - Required start station information

  """
  @spec list_tickets(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def list_tickets(client, opts \\ []) do
    request = %{
      language: Keyword.get(opts, :language, "de"),
      version: Keyword.get(opts, :version, 1),
      filterType: Keyword.get(opts, :filter_type, "NO_FILTER"),
      stationKey: Keyword.get(opts, :station_key)
    }
    |> filter_nil_values()

    Client.post(client, "/gti/public/ticketList", request)
  end

  # Private helper functions

  defp filter_nil_values(map) do
    map
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
