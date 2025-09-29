# geofox_ex

An Elixir client library for the Hamburg Public Transport (HVV) Geofox API.

The Geofox API provides public transport information for the Hamburg metropolitan area, including route planning, real-time departures, station information, and tariff calculations.

## Installation

Add `geofox_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:geofox_ex, "~> 0.1.0"}
  ]
end
```

## Configuration

```elixir
config :geofox,
  user: "your_user_id",
  password: "your_secret_key"
```

## Usage

### Basic Usage

```elixir
# Create a client
client = Geofox.new()

# Initialize session
{:ok, info} = Geofox.init(client)

# Search for stations
station = Geofox.station("Hauptbahnhof")
{:ok, results} = Geofox.check_name(client, station)
```

### Route Planning

```elixir
# Plan a route
start = Geofox.station("Hauptbahnhof", "Master:1")
dest = Geofox.station("Flughafen", "Master:3690")
time = Geofox.gti_time("2024-01-15", "14:30")

{:ok, routes} = Geofox.get_route(client, start, dest, time)
```

### Departure Information

```elixir
# Get departures for a station
station = Geofox.station("Hauptbahnhof", "Master:1")
time = Geofox.gti_time("2024-01-15", "14:30")

{:ok, departures} = Geofox.departure_list(client, station, time)
```

### Real-time Vehicle Information

```elixir
# Get vehicle positions in a bounding box
lower_left = Geofox.coordinate(9.9, 53.5)
upper_right = Geofox.coordinate(10.1, 53.6)
bbox = Geofox.bounding_box(lower_left, upper_right)

{:ok, vehicles} = Geofox.get_vehicle_map(client, bbox)
```

## Features

- **Route Planning**: Multi-modal journey planning with real-time data
- **Station Information**: Search stations, get details, accessibility info
- **Departures**: Real-time departure information with delays
- **Tariff Calculation**: Ticket prices and fare zone information
- **Vehicle Tracking**: Real-time vehicle positions and movements
- **Announcements**: Service disruptions and notifications

## Documentation

Full API documentation is available at [HexDocs](https://hexdocs.pm/geofox_ex).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
