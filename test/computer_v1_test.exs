defmodule ComputerV1Test do
  use ExUnit.Case
  doctest ComputerV1

  test "greets the world" do
    assert ComputerV1.hello() == :world
  end
end
