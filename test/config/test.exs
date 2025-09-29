import Config

# Configure test environment
config :geofox,
  # These should be set via environment variables in your CI/testing setup
  # Do not commit real credentials to version control
  user: System.get_env("GEOFOX_TEST_USER"),
  password: System.get_env("GEOFOX_TEST_PASSWORD")

# Configure ExUnit
config :logger, level: :warn
