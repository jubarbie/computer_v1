defmodule EqParserTest do
  use ExUnit.Case

  test "Equation parsing test" do
    assert EqParser.parseABC("3 * X^2 + 2 * X + 10") == {:ok, %{a: 3, b: 2, c: 10}}
	assert EqParser.parseABC("3*X^2+2*X+10") == {:ok, %{a: 3, b: 2, c: 10}}
	assert EqParser.parseABC("3*X^2+2*X-10") == {:ok, %{a: 3, b: 2, c: -10}}
	assert EqParser.parseABC("X^2+2*X-10") == {:ok, %{a: 3, b: 2, c: -10}}
	assert EqParser.parseABC("2*X-10") == {:error, "Malformed equation"}
  end
end
