defmodule Geofox.Utils.Validation do
  @moduledoc """
  Validation utilities for postal codes and location names from the Geofox API.

  This module provides functions for validating whether postal codes are within
  the HVV service area and for searching and validating location names.
  """

  alias Geofox.Client
  alias Geofox.Types

  @doc """
  Check if a postal code is within the HVV service area.

  This function validates whether a given postal code falls within the
  Hamburg public transport (HVV) service area, helping determine service
  availability for addresses.

  ## Parameters

    * `client` - The Geofox client
    * `postal_code` - The postal code to check (as integer)
    * `opts` - Optional parameters

  ## Options

    * `:language` - Language code (default: "de")
    * `:version` - API version (default: 1)
    * `:filter_type` - Filter type (default: "NO_FILTER")

  ## Examples

      # Check if a Hamburg postal code is in HVV area
      {:ok, result} = Geofox.Utils.Validation.check_postal_code(client, 20095)

      is_hvv = result["isHVV"]  # true or false

      # Check a postal code outside Hamburg
      {:ok, result} = Geofox.Utils.Validation.check_postal_code(client, 10115)
      # Likely returns isHVV: false

  ## Returns

  The response includes:
  - `isHVV` - Boolean indicating whether the postal code is within HVV service area

  """
  @spec check_postal_code(Client.t(), integer(), keyword()) :: {:ok, map()} | {:error, term()}
  def check_postal_code(client, postal_code, opts \\ []) do
    request = %{
      language: Keyword.get(opts, :language, "de"),
      version: Keyword.get(opts, :version, 1),
      filterType: Keyword.get(opts, :filter_type, "NO_FILTER"),
      postalCode: postal_code
    }
    |> filter_nil_values()

    Client.post(client, "/gti/public/checkPostalCode", request)
  end

  @doc """
  Search for and validate location names.

  This function searches for locations matching the given name and returns
  detailed information including coordinates, distances, and travel times.
  It's similar to the check_name function in Core.Stations but provides
  additional validation features.

  ## Parameters

    * `client` - The Geofox client
    * `name_info` - Location information as `t:Types.sd_name/0`
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

      # Search and validate a station name
      name_info = %{name: "Hauptbahnhof", type: "STATION"}
      {:ok, results} = Geofox.Utils.Validation.check_name(client, name_info)

      # Search with distance and travel time information
      {:ok, results} = Geofox.Utils.Validation.check_name(client, name_info,
        max_distance: 1000,
        tariff_details: true
      )

  ## Returns

  The response includes:
  - `results` - List of matching locations with:
    - Basic location information (name, id, type, coordinates)
    - `distance` - Distance in meters (if applicable)
    - `time` - Travel time in minutes (if applicable)
    - Additional validation-specific metadata

  """
  @spec check_name(Client.t(), Types.sd_name(), keyword()) :: {:ok, map()} | {:error, term()}
  def check_name(client, name_info, opts \\ []) do
    request = %{
      language: Keyword.get(opts, :language, "de"),
      version: Keyword.get(opts, :version, 1),
      filterType: Keyword.get(opts, :filter_type, "NO_FILTER"),
      theName: name_info,
      maxList: Keyword.get(opts, :max_list),
      maxDistance: Keyword.get(opts, :max_distance),
      coordinateType: Keyword.get(opts, :coordinate_type, "EPSG_4326"),
      tariffDetails: Keyword.get(opts, :tariff_details, false),
      allowTypeSwitch: Keyword.get(opts, :allow_type_switch, true)
    }
    |> filter_nil_values()

    Client.post(client, "/gti/public/checkName", request)
  end

  # Private helper functions

  defp filter_nil_values(map) do
    map
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
