defmodule Geofox.Client do
  @moduledoc """
  HTTP client for the HVV Geofox API.

  This module provides a unified interface for making HTTP requests to the Geofox API
  with proper HMAC-SHA1 authentication and response processing.

  ## Authentication

  The Geofox API requires HMAC-SHA1 authentication using these headers:
  - `geofox-auth-user`: Application ID (provided by HBT GmbH)
  - `geofox-auth-signature`: HMAC-SHA1 signature of the request body
  - `geofox-auth-type`: Always "HmacSHA1"

  ## Rate Limiting

  The API has a rate limit of approximately 1 request per second on average.
  Exceeding this will result in temporary access suspension.
  """

  import Bitwise
  alias Geofox.Utils.ErrorHandler

  @type t :: Req.Request.t()

  @default_base_url "https://gti.geofox.de"
  @default_timeout 30_000

  @doc """
  Create a new Geofox API client.

  ## Options

    * `:base_url` - Base URL for the API (default: "https://gti.geofox.de")
    * `:timeout` - Request timeout in milliseconds (default: 30000)
    * `:headers` - Additional headers to include in requests
    * `:user` - Application ID for authentication (required for most endpoints)
    * `:password` - Password for HMAC-SHA1 signature generation (required for auth)
    * `:platform` - Platform identifier (e.g., "ios", "android", "web", "mobile")
    * `:retry` - Retry configuration (default: false)
    * `:max_retries` - Maximum number of retries (default: 3)

  ## Examples

      # Public endpoints (no auth required)
      client = Geofox.Client.new()

      # Authenticated client
      client = Geofox.Client.new(
        user: "your_user_id",
        password: "your_secret_key",
        platform: "web"
      )

  """
  @spec new(keyword()) :: t()
  def new(opts \\ []) do
    base_url = get_config_value(opts, :base_url, @default_base_url)
    timeout = get_config_value(opts, :timeout, @default_timeout)
    headers = Keyword.get(opts, :headers, [])
    user = get_config_value(opts, :user, nil)
    password = get_config_value(opts, :password, nil)
    platform = get_config_value(opts, :platform, nil)
    retry = Keyword.get(opts, :retry, false)
    max_retries = Keyword.get(opts, :max_retries, 3)

    request_options = [
      base_url: base_url,
      receive_timeout: timeout,
      headers: build_default_headers(headers, platform),
      json: Jason
    ]

    request_options =
      if retry do
        Keyword.put(request_options, :retry, max_retries)
      else
        request_options
      end

    client = Req.new(request_options)

    # Store auth credentials in client for signature generation
    if user && password do
      Req.Request.put_private(client, :geofox_auth, %{user: user, password: password})
    else
      client
    end
  end

  @doc """
  Make a POST request to the Geofox API.

  ## Parameters

    * `client` - The Req client instance
    * `path` - API endpoint path (e.g., "/gti/public/getRoute")
    * `body` - Request body (will be JSON encoded)
    * `opts` - Additional request options

  ## Returns

    * `{:ok, response_body}` - Success with parsed response
    * `{:error, reason}` - Error with reason

  ## Examples

      request_body = %{
        language: "de",
        version: 1,
        filterType: "NO_FILTER"
      }

      case Geofox.Client.post(client, "/gti/public/init", request_body) do
        {:ok, response} -> IO.inspect(response)
        {:error, error_reason} -> IO.puts("Error: " <> inspect(error_reason))
      end

  """
  @spec post(t(), String.t(), map(), keyword()) :: {:ok, map()} | {:error, term()}
  def post(client, path, body, opts \\ []) do
    # Add authentication headers if credentials are available
    headers = build_auth_headers(client, body)

    request_opts = [
      url: path,
      json: body,  # Let Req handle JSON encoding
      headers: headers
    ] ++ opts

    case Req.post(client, request_opts) do
      {:ok, %Req.Response{status: status, body: response_body}} when status in 200..299 ->
        ErrorHandler.check_response(response_body)

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, exception} ->
        {:error, {:request_failed, exception}}
    end
  end

  @doc """
  Make a GET request to the Geofox API.

  Less commonly used for the Geofox API since most endpoints are POST,
  but included for completeness.
  """
  @spec get(t(), String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def get(client, path, opts \\ []) do
    request_opts = [url: path] ++ opts
    case Req.get(client, request_opts) do
      {:ok, %Req.Response{status: status, body: response_body}} when status in 200..299 ->
        ErrorHandler.check_response(response_body)

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, {:http_error, status, body}}

      {:error, exception} ->
        {:error, {:request_failed, exception}}
    end
  end

  # Private helper functions

  defp get_config_value(opts, key, default) do
    Keyword.get(opts, key) ||
      Application.get_env(:geofox, key) ||
      default
  end

  defp build_default_headers(base_headers, platform) do
    default_headers = [
      {"Content-Type", "application/json; charset=UTF-8"},
      {"Accept", "application/json"},
      {"Accept-Encoding", "gzip, deflate"},
      {"User-Agent", "geofox_ex/#{Application.spec(:geofox, :vsn) || "dev"}"},
      {"Connection", "Keep-Alive"}
    ]

    platform_headers =
      if platform do
        [{"X-Platform", platform}]
      else
        []
      end

    trace_id_headers = [{"X-TraceId", generate_trace_id()}]

    default_headers
    |> Kernel.++(platform_headers)
    |> Kernel.++(trace_id_headers)
    |> Kernel.++(base_headers)
    |> Enum.uniq_by(fn {key, _} -> String.downcase(key) end)
  end

  defp build_auth_headers(client, body_map) do
    case Req.Request.get_private(client, :geofox_auth) do
      %{user: user, password: password} ->
        # Encode the body for signature generation
        json_body = Jason.encode!(body_map)
        signature = generate_hmac_signature(json_body, password)
        [
          {"geofox-auth-user", user},
          {"geofox-auth-type", "HmacSHA1"},
          {"geofox-auth-signature", signature}
        ]

      _ ->
        []
    end
  end

  defp generate_hmac_signature(message, key) do
    :crypto.mac(:hmac, :sha, key, message)
    |> Base.encode64()
  end

  defp generate_trace_id do
    # Generate a UUID v4 for request tracing
    <<u0::32, u1::16, u2::16, u3::16, u4::48>> = :crypto.strong_rand_bytes(16)

    # Set version (4) and variant bits
    u2_modified = (u2 &&& 0x0FFF) ||| 0x4000
    u3_modified = (u3 &&& 0x3FFF) ||| 0x8000

    <<u0::32, u1::16, u2_modified::16, u3_modified::16, u4::48>>
    |> Base.encode16(case: :lower)
    |> String.replace(~r/(.{8})(.{4})(.{4})(.{4})(.{12})/, "\\1-\\2-\\3-\\4-\\5")
  end
end
