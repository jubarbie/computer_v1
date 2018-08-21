defmodule ComputerV1Test do
  use ExUnit.Case
  doctest ComputerV1

  test "Square root of 2 4 6" do
    assert ComputerV1.resolve([a: 2, b: 5, c: -3]) == {:two, [x1: -3,x2: 0.5]}
  end
end
