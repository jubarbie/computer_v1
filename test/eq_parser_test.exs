defmodule EqParserTest do
  use ExUnit.Case

  test "Equation parsing test" do
    assert EqParser.fromString("3 * X^2 + 2 * X + 10+ 43*X2=0") == {:ok, %{2 => 46, 1 => 2, 0 => 10}}
    assert EqParser.fromString("3 * X^2 + 2 * X + 10 = 3x") == {:ok, %{2 => 3, 1 => -1, 0 => 10}}

    assert EqParser.fromString("3*X^2+2*X+10=0=43") ==
             {:error, %{message: "Equation must have 2 sides", data: ["3*X^2+2*X+10", "0", "43"]}}

    assert EqParser.fromString("3*X^2+2*X-10") ==
             {:error, %{message: "Equation must have 2 sides", data: ["3*X^2+2*X-10"]}}

    assert EqParser.fromString("X^2+2*X-10 = 0") == {:ok, %{2 => 1, 1 => 2, 0 => -10}}
    assert EqParser.fromString("2*X-10=2x2+-12") == {:error, %{message: "Parsing error"}}
    assert EqParser.fromString("-32*X-10+2X2=2x2+12") == {:ok, %{2 => 0, 1 => -32, 0 => -22}}
    assert EqParser.fromString("-32*X-10+2.3X2=+12") == {:ok, %{2 => 2.3, 1 => -32, 0 => -22}}
  end

  test "Parse operations" do
    assert EqParser.parseOperations("2+4+3") ==
             {:ok,
              [
                %{sign: ?+, segment: "2"},
                %{sign: ?+, segment: "4"},
                %{sign: ?+, segment: "3"}
              ]}

    assert EqParser.parseOperations("2-4+3") ==
             {:ok,
              [
                %{sign: ?+, segment: "2"},
                %{sign: ?-, segment: "4"},
                %{sign: ?+, segment: "3"}
              ]}

    assert EqParser.parseOperations("-12X2-4+23") ==
             {:ok,
              [
                %{sign: ?-, segment: "12X2"},
                %{sign: ?-, segment: "4"},
                %{sign: ?+, segment: "23"}
              ]}
  end

  test "Parse segment" do
    assert EqParser.parseSegment(%{sign: ?+, segment: "2X2"}) == {:ok, %{2 => 2}}
    assert EqParser.parseSegment(%{sign: ?-, segment: "2X2"}) == {:ok, %{2 => -2}}
    assert EqParser.parseSegment(%{sign: ?-, segment: "2X^2"}) == {:ok, %{2 => -2}}

    assert EqParser.parseSegment(%{sign: ?-, segment: "2Y^2"}) ==
             {:error, %{message: "Error while parsing equation: 2Y^2"}}

    assert EqParser.parseSegment(%{sign: ?-, segment: "2*X^2"}) == {:ok, %{2 => -2}}
    assert EqParser.parseSegment(%{sign: ?-, segment: "-2*X^2"}) == {:ok, %{2 => 2}}

    assert EqParser.parseSegment(%{sign: ?-, segment: "-2*X^3"}) ==  {:ok, %{3 => 2.0}}

    assert EqParser.parseSegment(%{sign: ?+, segment: "-203*X^1"}) == {:ok, %{1 => -203}}
    assert EqParser.parseSegment(%{sign: ?+, segment: "23*X"}) == {:ok, %{1 => 23}}
  end

  test "Create model" do
    assert EqParser.createModel([%{sign: ?+, segment: "2X2"}]) == {:ok, %{2 => 2.0}}
    assert EqParser.createModel([%{sign: ?-, segment: "2X"}]) == {:ok, %{1 => -2.0}}
    assert EqParser.createModel([%{sign: ?-, segment: "2"}]) == {:ok, %{0 => -2.0}}
    assert EqParser.createModel([%{sign: ?-, segment: "2.3"}]) == {:ok, %{0 => -2.3}}
    assert EqParser.createModel([
             %{sign: ?-, segment: "2"},
             %{sign: ?+, segment: "2X2"},
             %{sign: ?-, segment: "2"},
             %{sign: ?+, segment: "2X^0"}
           ]) == {:ok, %{2 => 2, 0 => -2}}
    assert EqParser.createModel([
             %{sign: ?-, segment: "2x2"},
             %{sign: ?+, segment: "-21X"}
           ]) == {:ok, %{2 => -2, 1 => -21}}
    assert EqParser.createModel([
             %{sign: ?-, segment: "2"},
             %{sign: ?+, segment: "2X2"},
             %{sign: ?-, segment: "2X"},
             %{sign: ?+, segment: "902X2"},
             %{sign: ?+, segment: "-2X2"},
             %{sign: ?+, segment: "2X^0"},
             %{sign: ?-, segment: "7X^1"}
           ]) == {:ok, %{2 => 902, 1 => -9, 0 => 0}}
  end
end
