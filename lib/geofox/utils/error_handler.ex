defmodule Geofox.Utils.ErrorHandler do
  @moduledoc """
  Error handling utilities for Geofox API responses.
  """

  @doc """
  Check an API response for error codes and return a normalized result.

  ## Examples

      {:ok, data} = response |> Geofox.Utils.ErrorHandler.check_response()
      {:error, reason} = response |> Geofox.Utils.ErrorHandler.check_response()

  """
  @spec check_response(map()) :: {:ok, map()} | {:error, term()}
  def check_response(%{"returnCode" => "OK"} = response) do
    {:ok, response}
  end

  def check_response(%{"returnCode" => error_code, "errorText" => error_text}) do
    {:error, {error_code, error_text}}
  end

  def check_response(%{"returnCode" => error_code}) do
    {:error, {error_code, "Unknown error"}}
  end

  def check_response(response) do
    {:error, {:unknown_response, response}}
  end

  @doc """
  Extract data from a successful API response, raising on errors.

  Useful for pipeline operations where you want to fail fast on API errors.
  """
  @spec extract_data!(map()) :: map()
  def extract_data!(%{"returnCode" => "OK"} = response) do
    response
  end

  def extract_data!(%{"returnCode" => error_code, "errorText" => error_text}) do
    raise "Geofox API Error: #{error_code} - #{error_text}"
  end

  def extract_data!(response) do
    raise "Geofox API Error: #{inspect(response)}"
  end

  @doc """
  Handle Tesla/HTTP client responses (used internally by Client module).
  """
  @spec handle_response({:ok, map()} | {:error, term()}) :: {:ok, map()} | {:error, term()}
  def handle_response({:ok, response}) do
    check_response(response)
  end

  def handle_response({:error, reason}) do
    {:error, reason}
  end

  # Handle direct response maps (for testing)
  def handle_response(response) when is_map(response) do
    check_response(response)
  end
end
