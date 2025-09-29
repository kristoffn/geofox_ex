defmodule MixHelper do
  @moduledoc """
  Helper functions for running different types of tests.
  """

  def integration_tests? do
    "--only integration" in System.argv() or
    "test/integration/" in System.argv()
  end

  def unit_tests_only? do
    "--exclude integration" in System.argv()
  end
end
