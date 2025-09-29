defmodule Geofox.Core.Lines do
  @moduledoc """
  Functions for retrieving line information from the Geofox API.
  """

  alias Geofox.Client

  @doc """
  List all available lines with optional subline information.

  ## Parameters

    * `client` - The Geofox client
    * `opts` - Optional parameters

  ## Options

    * `:language` - Language code (default: "de")
    * `:version` - API version (default: 1)
    * `:filter_type` - Filter type (default: "NO_FILTER")
    * `:with_sublines` - Include subline information (default: false)
    * `:data_release_id` - Data release ID to filter changes since a specific version
    * `:modification_types` - List of modification types to include (e.g., ["MAIN", "SEQUENCE"])

  ## Examples

      # Basic line listing
      {:ok, lines} = Geofox.Core.Lines.list_lines(client)

      # Include sublines and filter by modification types
      {:ok, lines} = Geofox.Core.Lines.list_lines(client,
        with_sublines: true,
        modification_types: ["MAIN", "SEQUENCE"]
      )

      # Get lines changed since a specific data release
      {:ok, lines} = Geofox.Core.Lines.list_lines(client,
        data_release_id: "2024-01-15",
        modification_types: ["MAIN"]
      )

  """
  @spec list_lines(Client.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def list_lines(client, opts \\ []) do
    request = %{
      language: Keyword.get(opts, :language, "de"),
      version: Keyword.get(opts, :version, 1),
      filterType: Keyword.get(opts, :filter_type, "NO_FILTER"),
      withSublines: Keyword.get(opts, :with_sublines, false),
      dataReleaseID: Keyword.get(opts, :data_release_id),
      modificationTypes: Keyword.get(opts, :modification_types)
    }
    |> filter_nil_values()

    Client.post(client, "/gti/public/listLines", request)
  end

  # Private helper functions

  defp filter_nil_values(map) do
    map
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end
end
