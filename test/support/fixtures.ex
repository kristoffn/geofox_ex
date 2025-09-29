defmodule Geofox.Fixtures do
  @moduledoc """
  Test fixtures for Geofox API responses and requests.
  """

  def station_fixture(name \\ "Hauptbahnhof", id \\ "Master:1") do
    %{
      name: name,
      id: id,
      type: "STATION"
    }
  end

  def coordinate_fixture(x \\ 10.006414, y \\ 53.552736) do
    %{
      x: x,
      y: y,
      type: "EPSG_4326"
    }
  end

  def gti_time_fixture(date \\ "2024-01-15", time \\ "14:30") do
    %{
      date: date,
      time: time
    }
  end

  def init_response_fixture do
    %{
      "returnCode" => "OK",
      "beginOfService" => "2024-01-01",
      "endOfService" => "2024-12-31",
      "id" => "test-system",
      "dataId" => "test-data-v1",
      "buildDate" => "2024-01-01",
      "buildTime" => "12:00:00",
      "buildText" => "Test Build",
      "version" => "1.0",
      "properties" => []
    }
  end

  def route_response_fixture do
    %{
      "returnCode" => "OK",
      "schedules" => [
        %{
          "start" => station_fixture("Hauptbahnhof", "Master:1"),
          "dest" => station_fixture("Flughafen", "Master:3690"),
          "time" => 1800,
          "footpathTime" => 120,
          "plannedDepartureTime" => "2024-01-15T14:30:00+01:00",
          "plannedArrivalTime" => "2024-01-15T15:15:00+01:00",
          "scheduleElements" => [
            %{
              "from" => %{
                "name" => "Hauptbahnhof",
                "id" => "Master:1",
                "type" => "STATION",
                "depTime" => gti_time_fixture("2024-01-15", "14:30")
              },
              "to" => %{
                "name" => "Flughafen",
                "id" => "Master:3690",
                "type" => "STATION",
                "arrTime" => gti_time_fixture("2024-01-15", "15:15")
              },
              "line" => %{
                "name" => "S1",
                "type" => %{"simpleType" => "TRAIN"},
                "id" => "HVV:S1"
              }
            }
          ]
        }
      ]
    }
  end

  def departure_response_fixture do
    %{
      "returnCode" => "OK",
      "time" => gti_time_fixture(),
      "departures" => [
        %{
          "line" => %{
            "name" => "S1",
            "type" => %{"simpleType" => "TRAIN"},
            "direction" => "Wedel",
            "id" => "HVV:S1"
          },
          "timeOffset" => 5,
          "delay" => 2,
          "extra" => false,
          "cancelled" => false,
          "platform" => "3",
          "realtimePlatform" => "3"
        }
      ]
    }
  end

  def check_name_response_fixture do
    %{
      "returnCode" => "OK",
      "results" => [
        %{
          "name" => "Hauptbahnhof",
          "id" => "Master:1",
          "type" => "STATION",
          "city" => "Hamburg",
          "combinedName" => "Hauptbahnhof, Hamburg",
          "coordinate" => coordinate_fixture(),
          "hasStationInformation" => true
        }
      ]
    }
  end

  def announcements_response_fixture do
    %{
      "returnCode" => "OK",
      "announcements" => [
        %{
          "id" => "test-announcement-1",
          "summary" => "Service disruption",
          "description" => "Due to construction work, there are delays on line U1.",
          "validities" => [
            %{
              "begin" => "2024-01-15T06:00:00+01:00",
              "end" => "2024-01-15T22:00:00+01:00"
            }
          ],
          "lastModified" => "2024-01-15T14:30:00+01:00",
          "planned" => true,
          "broadcastRelevant" => false
        }
      ],
      "lastUpdate" => "2024-01-15T14:30:00+01:00"
    }
  end

  def vehicle_map_response_fixture do
    %{
      "returnCode" => "OK",
      "journeys" => [
        %{
          "journeyID" => "test-journey-1",
          "line" => %{
            "name" => "S1",
            "type" => %{"simpleType" => "TRAIN"}
          },
          "vehicleType" => "S_BAHN",
          "realtime" => true,
          "segments" => [
            %{
              "startStopPointKey" => "stop1",
              "endStopPointKey" => "stop2",
              "startStationName" => "Hauptbahnhof",
              "startStationKey" => "Master:1",
              "startDateTime" => 1_705_317_000,
              "endStationName" => "Dammtor",
              "endStationKey" => "Master:2",
              "endDateTime" => 1_705_317_300,
              "destination" => "Wedel",
              "track" => %{
                "track" => [10.006414, 53.552736, 10.021, 53.560],
                "coordinateType" => "EPSG_4326"
              }
            }
          ]
        }
      ]
    }
  end

  def error_response_fixture(code \\ "ERROR_TEXT", message \\ "Invalid request") do
    %{
      "returnCode" => code,
      "errorText" => message,
      "errorDevInfo" => "Debug information for developers"
    }
  end
end
