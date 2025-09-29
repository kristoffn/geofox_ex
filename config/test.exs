import Config

config :geofox,
  user: System.get_env("GEOFOX_TEST_USER"),
  password: System.get_env("GEOFOX_TEST_PASSWORD")

config :logger, level: :warn
