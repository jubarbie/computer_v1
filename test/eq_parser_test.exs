defmodule EqParserTest do
  use ExUnit.Case

  test "3 * X^2 + 2 * X + 10 = 0" do
    assert EqParser.parse("3 * X^2 + 2 * X + 10 = 0") == {:ok, {:deg2, [a: 3, b: 2, c: 10]}}
  end
end
