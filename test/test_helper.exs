ExUnit.start()

# Configure test environment
Application.put_env(:geofox, :user, System.get_env("GEOFOX_TEST_USER"))
Application.put_env(:geofox, :password, System.get_env("GEOFOX_TEST_PASSWORD"))
