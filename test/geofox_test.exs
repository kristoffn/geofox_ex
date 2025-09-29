# test/geofox_test.exs
defmodule GeofoxTest do
  use ExUnit.Case, async: true

  setup do
    # Mock successful API responses
    bypass = Bypass.open()
    client = Geofox.Client.new(base_url: "http://localhost:#{bypass.port}")

    {:ok, bypass: bypass, client: client}
  end

  describe "client creation" do
    test "creates client with default options" do
      client = Geofox.new()
      assert %Req.Request{} = client
    end

    test "creates client with custom options" do
      client = Geofox.new(
        timeout: 60_000,
        user: "test_user",
        password: "test_pass"
      )
      assert %Req.Request{} = client
    end
  end

  describe "helper functions" do
    test "coordinate/3 creates coordinate structure" do
      coord = Geofox.coordinate(53.5511, 9.9937)

      assert coord == %{
        "x" => 53.5511,
        "y" => 9.9937,
        "type" => "EPSG_4326"
      }
    end

    test "coordinate/3 with custom type" do
      coord = Geofox.coordinate(53.5511, 9.9937, "EPSG_31467")

      assert coord["type"] == "EPSG_31467"
    end

    test "gti_time/2 creates time structure" do
      time = Geofox.gti_time("2024-01-15", "14:30")

      assert time == %{
        "date" => "2024-01-15",
        "time" => "14:30"
      }
    end

    test "station/3 creates station structure" do
      station = Geofox.station("Hauptbahnhof", "Master:1")

      assert station == %{
        "name" => "Hauptbahnhof",
        "id" => "Master:1",
        "type" => "STATION"
      }
    end

    test "bounding_box/2 creates bounding box" do
      lower = Geofox.coordinate(9.9, 53.5)
      upper = Geofox.coordinate(10.1, 53.6)
      bbox = Geofox.bounding_box(lower, upper)

      assert bbox == %{
        "lowerLeft" => lower,
        "upperRight" => upper
      }
    end
  end

  describe "API endpoints" do
    test "init/2 makes request to init endpoint", %{bypass: bypass, client: client} do
      response_body = %{
        "returnCode" => "OK",
        "beginOfService" => "2024-01-01",
        "endOfService" => "2024-12-31",
        "version" => "1.0",
        "id" => "test-system",
        "dataId" => "test-data"
      }

      Bypass.expect_once(bypass, "POST", "/gti/public/init", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)

        # Try to parse the JSON
        request = case Jason.decode(body) do
          {:ok, parsed} ->
            parsed
          {:error, _} ->
            %{}
        end

        assert request["language"] == "de"
        assert request["version"] == 1
        assert request["filterType"] == "NO_FILTER"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, response} = Geofox.init(client)
      assert response["returnCode"] == "OK"
      assert response["beginOfService"] == "2024-01-01"
    end

    test "get_route/5 makes request to route endpoint", %{bypass: bypass, client: client} do
      start = Geofox.station("Hauptbahnhof", "Master:1")
      dest = Geofox.station("Flughafen", "Master:3690")
      time = Geofox.gti_time("2024-01-15", "14:30")

      response_body = %{
        "returnCode" => "OK",
        "schedules" => [
          %{
            "start" => start,
            "dest" => dest,
            "time" => 1800,
            "scheduleElements" => []
          }
        ]
      }

      Bypass.expect_once(bypass, "POST", "/gti/public/getRoute", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        request = Jason.decode!(body)

        assert request["start"] == start
        assert request["dest"] == dest
        assert request["time"] == time
        assert request["timeIsDeparture"] == true

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, response} = Geofox.get_route(client, start, dest, time)
      assert response["returnCode"] == "OK"
      assert length(response["schedules"]) == 1
    end

    test "departure_list/4 makes request to departure endpoint", %{bypass: bypass, client: client} do
      station = Geofox.station("Hauptbahnhof", "Master:1")
      time = Geofox.gti_time("2024-01-15", "14:30")

      response_body = %{
        "returnCode" => "OK",
        "time" => time,
        "departures" => [
          %{
            "line" => %{"name" => "S1", "type" => %{"simpleType" => "TRAIN"}},
            "timeOffset" => 5,
            "delay" => 0
          }
        ]
      }

      Bypass.expect_once(bypass, "POST", "/gti/public/departureList", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        request = Jason.decode!(body)

        assert request["station"] == station
        assert request["time"] == time
        assert request["departure"] == true

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, response} = Geofox.departure_list(client, station, time)
      assert response["returnCode"] == "OK"
      assert length(response["departures"]) == 1
    end

    test "check_name/3 makes request to checkName endpoint", %{bypass: bypass, client: client} do
      name_info = %{name: "Hauptbahnhof", type: "STATION"}

      response_body = %{
        "returnCode" => "OK",
        "results" => [
          %{
            "name" => "Hauptbahnhof",
            "id" => "Master:1",
            "type" => "STATION",
            "city" => "Hamburg",
            "coordinate" => %{"x" => 10.006414, "y" => 53.552736}
          }
        ]
      }

      Bypass.expect_once(bypass, "POST", "/gti/public/checkName", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        request = Jason.decode!(body)

        assert request["theName"]["name"] == name_info.name
        assert request["theName"]["type"] == name_info.type
        assert request["coordinateType"] == "EPSG_4326"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, response} = Geofox.check_name(client, name_info)
      assert response["returnCode"] == "OK"
      assert length(response["results"]) == 1
    end

    test "get_vehicle_map/3 makes request to vehicle map endpoint", %{bypass: bypass, client: client} do
      bbox = Geofox.bounding_box(
        Geofox.coordinate(9.9, 53.5),
        Geofox.coordinate(10.1, 53.6)
      )

      response_body = %{
        "returnCode" => "OK",
        "journeys" => [
          %{
            "journeyID" => "test-journey",
            "line" => %{"name" => "S1"},
            "vehicleType" => "S_BAHN",
            "segments" => []
          }
        ]
      }

      Bypass.expect_once(bypass, "POST", "/gti/public/getVehicleMap", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        request = Jason.decode!(body)

        assert request["boundingBox"] == bbox
        assert request["coordinateType"] == "EPSG_4326"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, response} = Geofox.get_vehicle_map(client, bbox)
      assert response["returnCode"] == "OK"
      assert length(response["journeys"]) == 1
    end

    test "get_announcements/2 makes request to announcements endpoint", %{bypass: bypass, client: client} do
      response_body = %{
        "returnCode" => "OK",
        "announcements" => [
          %{
            "id" => "test-announcement",
            "description" => "Service disruption on line U1",
            "validities" => [],
            "lastModified" => "2024-01-15T14:30:00+01:00"
          }
        ],
        "lastUpdate" => "2024-01-15T14:30:00+01:00"
      }

      Bypass.expect_once(bypass, "POST", "/gti/public/getAnnouncements", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        request = Jason.decode!(body)

        assert request["language"] == "de"
        assert request["full"] == false

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response_body))
      end)

      assert {:ok, response} = Geofox.get_announcements(client)
      assert response["returnCode"] == "OK"
      assert length(response["announcements"]) == 1
    end
  end

  describe "error handling" do
    test "handles API error responses", %{bypass: bypass, client: client} do
      error_response = %{
        "returnCode" => "ERROR_TEXT",
        "errorText" => "Invalid request",
        "errorDevInfo" => "Debug information"
      }

      Bypass.expect_once(bypass, "POST", "/gti/public/init", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(error_response))
      end)

      assert {:error, {"ERROR_TEXT", "Invalid request"}} = Geofox.init(client)
    end

    test "handles HTTP errors", %{bypass: bypass, client: client} do
      Bypass.expect_once(bypass, "POST", "/gti/public/init", fn conn ->
        Plug.Conn.resp(conn, 500, "Internal Server Error")
      end)

      assert {:error, _} = Geofox.init(client)
    end

    test "handles network errors" do
      # Use a non-routable IP address that will definitely fail
      client = Geofox.Client.new(base_url: "http://192.0.2.1:1")

      assert {:error, _} = Geofox.init(client)
    end
  end

  describe "request options" do
    test "get_route/5 with custom options", %{bypass: bypass, client: client} do
      start = Geofox.station("Hauptbahnhof", "Master:1")
      dest = Geofox.station("Flughafen", "Master:3690")
      time = Geofox.gti_time("2024-01-15", "14:30")

      Bypass.expect_once(bypass, "POST", "/gti/public/getRoute", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        request = Jason.decode!(body)

        assert request["numberOfSchedules"] == 5
        assert request["withPaths"] == true
        assert request["realtime"] == "REALTIME"

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(%{"returnCode" => "OK", "schedules" => []}))
      end)

      opts = [
        number_of_schedules: 5,
        with_paths: true,
        realtime: "REALTIME"
      ]

      assert {:ok, _} = Geofox.get_route(client, start, dest, time, opts)
    end

    test "departure_list/4 with filtering options", %{bypass: bypass, client: client} do
      station = Geofox.station("Hauptbahnhof", "Master:1")
      time = Geofox.gti_time("2024-01-15", "14:30")

      Bypass.expect_once(bypass, "POST", "/gti/public/departureList", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        request = Jason.decode!(body)

        assert request["maxList"] == 10
        assert request["useRealtime"] == true
        assert request["serviceTypes"] == ["U_BAHN", "S_BAHN"]

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(%{"returnCode" => "OK", "departures" => []}))
      end)

      opts = [
        max_list: 10,
        use_realtime: true,
        service_types: ["U_BAHN", "S_BAHN"]
      ]

      assert {:ok, _} = Geofox.departure_list(client, station, time, opts)
    end
  end
end
