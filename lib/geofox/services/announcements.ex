defmodule Geofox.Services.Announcements do
  @moduledoc """
  Service announcements and disruption information functions for the Geofox API.

  This module provides functions for retrieving current announcements, service disruptions,
  and other important notices affecting public transportation services.
  """

  alias Geofox.Client

  @doc """
  Get service announcements and disruption information.

  This function retrieves current announcements including service disruptions,
  schedule changes, construction notices, and other important information
  affecting public transportation services.

  ## Parameters

    * `client` - The Geofox client
    * `opts` - Optional parameters

  ## Options

    * `:language` - Language code (default: "de")
    * `:version` - API version (default: 1)
    * `:filter_type` - Filter type (default: "NO_FILTER")
    * `:names` - List of line/station names to filter announcements
    * `:time_range` - Time range object with begin and end times to filter announcements
    * `:full` - Return full announcement details (default: false)
    * `:filter_planned` - Filter planned announcements: "NO_FILTER", "ONLY_PLANNED", "ONLY_UNPLANNED"
    * `:show_broadcast_relevant` - Include broadcast-relevant announcements (default: false)

  ## Examples

      # Get all current announcements
      {:ok, announcements} = Geofox.Services.Announcements.get_announcements(client)

      # Get detailed announcements for specific lines
      {:ok, announcements} = Geofox.Services.Announcements.get_announcements(client,
        names: ["U1", "S1", "Bus 112"],
        full: true
      )

      # Get announcements within a specific time range
      time_range = %{
        begin: "2024-01-15T00:00:00+01:00",
        end: "2024-01-15T23:59:59+01:00"
      }
      {:ok, announcements} = Geofox.Services.Announcements.get_announcements(client,
        time_range: time_range,
        filter_planned: "ONLY_UNPLANNED"
      )

  ## Returns

  The response includes:
  - `announcements` - List of announcement objects with details like:
    - `summary` - Brief description of the announcement
    - `description` - Detailed announcement text
    - `locations` - Affected lines/stations
    - `validities` - Time periods when the announcement is valid
    - `links` - Related URLs for more information
  - `lastUpdate` - Timestamp of the last update

  """
  @spec get_announcements(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def get_announcements(client, opts \\ []) do
    request = %{
      language: Keyword.get(opts, :language, "de"),
      version: Keyword.get(opts, :version, 1),
      filterType: Keyword.get(opts, :filter_type, "NO_FILTER"),
      names: Keyword.get(opts, :names),
      timeRange: Keyword.get(opts, :time_range),
      full: Keyword.get(opts, :full, false),
      filterPlanned: Keyword.get(opts, :filter_planned),
      showBroadcastRelevant: Keyword.get(opts, :show_broadcast_relevant, false)
    }
    |> filter_nil_values()

    Client.post(client, "/gti/public/getAnnouncements", request)
  end

  # Private helper functions

  defp filter_nil_values(map) do
    map
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
