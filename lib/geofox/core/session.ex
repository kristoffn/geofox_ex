defmodule Geofox.Core.Session do
  @moduledoc """
  Session and initialization functions for the Geofox API.

  This module handles API initialization which provides system information,
  service availability, and validates connectivity.
  """

  alias Geofox.Client

  @doc """
  Initialize a session with the Geofox API to get service information and validate connectivity.

  The init endpoint provides general system information including:
  - Service availability period (beginOfService, endOfService)
  - System version and build information
  - Data version identifier
  - Custom properties if requested

  ## Parameters

    * `client` - The Geofox client
    * `opts` - Optional parameters

  ## Options

    * `:language` - Language code (default: "de")
    * `:version` - API version (default: 1)
    * `:filter_type` - Filter type (default: "NO_FILTER")
    * `:properties` - List of property objects to request specific system properties

  ## Examples

      # Basic initialization
      {:ok, info} = Geofox.Core.Session.init(client)

      # Access system information
      begin_service = info["beginOfService"]  # e.g., "2024-01-01"
      end_service = info["endOfService"]      # e.g., "2024-12-31"
      version = info["version"]               # API version

      # Initialize with custom properties
      properties = [
        %{key: "someProperty", value: "someValue"}
      ]
      {:ok, info} = Geofox.Core.Session.init(client, properties: properties)

  ## Returns

  The response includes:
  - `beginOfService` - Start date of service data
  - `endOfService` - End date of service data
  - `id` - System identifier
  - `dataId` - Data version identifier
  - `buildDate`, `buildTime`, `buildText` - Build information
  - `version` - API version
  - `properties` - Any requested properties

  """
  @spec init(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def init(client, opts \\ []) do
    request = %{
      language: Keyword.get(opts, :language, "de"),
      version: Keyword.get(opts, :version, 1),
      filterType: Keyword.get(opts, :filter_type, "NO_FILTER"),
      properties: Keyword.get(opts, :properties, [])
    }
    |> filter_nil_values()

    Client.post(client, "/gti/public/init", request)
  end

  # Private helper functions

  defp filter_nil_values(map) do
    map
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
