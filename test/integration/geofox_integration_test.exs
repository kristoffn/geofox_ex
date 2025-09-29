defmodule Geofox.IntegrationTest do
  use ExUnit.Case, async: false

  @moduletag :integration

  # Only run these tests when explicitly requested with:
  # mix test --only integration
  # or: mix test test/integration/

  setup_all do
    # Skip if no credentials are configured
    user = Application.get_env(:geofox, :user)
    password = Application.get_env(:geofox, :password)

    if is_nil(user) or is_nil(password) do
      {:skip, "No API credentials configured. Set :geofox, :user and :geofox, :password in config."}
    else
      client = Geofox.new(user: user, password: password)
      {:ok, client: client}
    end
  end

  describe "real API integration" do
    @tag :slow
    test "init endpoint returns system information", %{client: client} do
      assert {:ok, response} = Geofox.init(client)

      # Basic response structure checks
      assert is_map(response)
      assert Map.has_key?(response, "returnCode")

      if response["returnCode"] == "OK" do
        assert Map.has_key?(response, "beginOfService")
        assert Map.has_key?(response, "endOfService")
        assert Map.has_key?(response, "version")
      end
    end

    @tag :slow
    test "check_name finds Hamburg Hauptbahnhof", %{client: client} do
      name_info = Geofox.station("Hauptbahnhof")

      assert {:ok, response} = Geofox.check_name(client, name_info)

      if response["returnCode"] == "OK" do
        results = response["results"]
        assert is_list(results)
        assert length(results) > 0

        # Should find at least one result containing "Hauptbahnhof"
        hauptbahnhof_found = Enum.any?(results, fn result ->
          String.contains?(result["name"], "Hauptbahnhof")
        end)
        assert hauptbahnhof_found
      end
    end

    @tag :slow
    test "get_route finds routes between well-known stations", %{client: client} do
      start = Geofox.station("Hauptbahnhof")
      dest = Geofox.station("Flughafen")

      # Use current time + 1 hour for departure
      now = DateTime.utc_now() |> DateTime.add(3600, :second)
      time = Geofox.gti_time_from_datetime(now)

      assert {:ok, response} = Geofox.get_route(client, start, dest, time)

      if response["returnCode"] == "OK" do
        schedules = response["schedules"]
        assert is_list(schedules)
        # Should find at least one route
        assert length(schedules) > 0
      end
    end

    @tag :slow
    test "departure_list returns departures for Hauptbahnhof", %{client: client} do
      station = Geofox.station("Hauptbahnhof", "Master:1")

      # Use current time
      now = DateTime.utc_now()
      time = Geofox.gti_time_from_datetime(now)

      assert {:ok, response} = Geofox.departure_list(client, station, time, max_list: 5)

      if response["returnCode"] == "OK" do
        departures = response["departures"]
        assert is_list(departures)
        # Hauptbahnhof should have departures
        assert length(departures) > 0
      end
    end

    @tag :slow
    test "get_announcements returns current service announcements", %{client: client} do
      assert {:ok, response} = Geofox.get_announcements(client)

      if response["returnCode"] == "OK" do
        announcements = response["announcements"]
        assert is_list(announcements)
        assert Map.has_key?(response, "lastUpdate")

        # Announcements may be empty if no current disruptions
        if length(announcements) > 0 do
          first_announcement = List.first(announcements)
          assert Map.has_key?(first_announcement, "description")
          assert Map.has_key?(first_announcement, "validities")
        end
      end
    end

    @tag :slow
    test "get_vehicle_map returns vehicles in Hamburg area", %{client: client} do
      # Bounding box around Hamburg city center
      lower_left = Geofox.coordinate(9.8, 53.4)
      upper_right = Geofox.coordinate(10.2, 53.7)
      bbox = Geofox.bounding_box(lower_left, upper_right)

      assert {:ok, response} = Geofox.get_vehicle_map(client, bbox, realtime: true)

      if response["returnCode"] == "OK" do
        journeys = response["journeys"]
        assert is_list(journeys)

        # Should find some vehicles in Hamburg
        if length(journeys) > 0 do
          first_journey = List.first(journeys)
          assert Map.has_key?(first_journey, "journeyID")
          assert Map.has_key?(first_journey, "line")
          assert Map.has_key?(first_journey, "vehicleType")
        end
      end
    end

    @tag :slow
    test "list_stations returns station data", %{client: client} do
      # Request a small subset to avoid large responses
      assert {:ok, response} = Geofox.list_stations(client)

      if response["returnCode"] == "OK" do
        stations = response["stations"]
        assert is_list(stations)
        assert length(stations) > 0

        first_station = List.first(stations)
        assert Map.has_key?(first_station, "id")
        assert Map.has_key?(first_station, "name")
      end
    end

    @tag :slow
    test "check_postal_code validates Hamburg postal codes", %{client: client} do
      # Hamburg postal code
      hamburg_plz = 20_095

      assert {:ok, response} = Geofox.check_postal_code(client, hamburg_plz)

      if response["returnCode"] == "OK" do
        assert Map.has_key?(response, "isHVV")
        # Hamburg postal codes should be in HVV area
        assert response["isHVV"] == true
      end
    end

    @tag :slow
    test "check_postal_code rejects non-Hamburg postal codes", %{client: client} do
      # Berlin postal code
      berlin_plz = 10_115

      assert {:ok, response} = Geofox.check_postal_code(client, berlin_plz)

      if response["returnCode"] == "OK" do
        assert Map.has_key?(response, "isHVV")
        # Berlin postal codes should not be in HVV area
        assert response["isHVV"] == false
      end
    end
  end

  describe "error handling in real API" do
    @tag :slow
    test "handles invalid station IDs gracefully", %{client: client} do
      invalid_station = Geofox.station("NonexistentStation", "INVALID:999999")
      time = Geofox.gti_time_from_datetime(DateTime.utc_now())

      # This should either return an error or empty results
      result = Geofox.departure_list(client, invalid_station, time)

      case result do
        {:ok, response} ->
          # If successful, should indicate no results or error in returnCode
          assert response["returnCode"] in ["OK", "ERROR_TEXT"]
        {:error, _reason} ->
          # Network or parsing error is also acceptable
          assert true
      end
    end

    @tag :slow
    test "handles invalid coordinates gracefully", %{client: client} do
      # Invalid bounding box (coordinates outside Earth)
      invalid_lower = Geofox.coordinate(-200, -100)
      invalid_upper = Geofox.coordinate(200, 100)
      invalid_bbox = Geofox.bounding_box(invalid_lower, invalid_upper)

      result = Geofox.get_vehicle_map(client, invalid_bbox)

      case result do
        {:ok, response} ->
          # Should handle gracefully
          assert is_map(response)
        {:error, _reason} ->
          # Error response is acceptable
          assert true
      end
    end
  end
end
