defmodule EqParserTest do
  use ExUnit.Case

  test "Equation parsing test" do
    assert EqParser.fromString("3 * X^2 + 2 * X + 10+ 43*X2=0") == {:ok, %{a: 46, b: 2, c: 10}}
    assert EqParser.fromString("3 * X^2 + 2 * X + 10 = 3x") == {:ok, %{a: 3, b: -1, c: 10}}

    assert EqParser.fromString("3*X^2+2*X+10=0=43") ==
             {:error, %{message: "Equation must have 2 sides", data: ["3*X^2+2*X+10", "0", "43"]}}

    assert EqParser.fromString("3*X^2+2*X-10") ==
             {:error, %{message: "Equation must have 2 sides", data: ["3*X^2+2*X-10"]}}

    assert EqParser.fromString("X^2+2*X-10 = 0") == {:ok, %{a: 1, b: 2, c: -10}}
    assert EqParser.fromString("2*X-10=2x2+-12") == {:error, %{message: "Parsing error"}}
    assert EqParser.fromString("-32*X-10+2X2=2x2+12") == {:ok, %{a: 0, b: -32, c: -22}}
    assert EqParser.fromString("-32*X-10+2.3X2=+12") == {:ok, %{a: 2.3, b: -32, c: -22}}
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

  test "Parse ABC" do
    assert EqParser.parseABC(%{sign: ?+, segment: "2X2"}) == {:ok, %{a: 2}}
    assert EqParser.parseABC(%{sign: ?-, segment: "2X2"}) == {:ok, %{a: -2}}
    assert EqParser.parseABC(%{sign: ?-, segment: "2X^2"}) == {:ok, %{a: -2}}

    assert EqParser.parseABC(%{sign: ?-, segment: "2Y^2"}) ==
             {:error, %{message: "Error while parsing equation: 2Y^2"}}

    assert EqParser.parseABC(%{sign: ?-, segment: "2*X^2"}) == {:ok, %{a: -2}}
    assert EqParser.parseABC(%{sign: ?-, segment: "-2*X^2"}) == {:ok, %{a: 2}}

    assert EqParser.parseABC(%{sign: ?-, segment: "-2*X^3"}) ==
             {:error, %{message: "Error while parsing equation: -2*X^3"}}

    assert EqParser.parseABC(%{sign: ?+, segment: "-203*X^1"}) == {:ok, %{b: -203}}
    assert EqParser.parseABC(%{sign: ?+, segment: "23*X"}) == {:ok, %{b: 23}}
  end

  test "Create model" do
    assert EqParser.createModel([%{sign: ?+, segment: "2X2"}]) == %{a: 2, b: 0, c: 0, error: []}
    assert EqParser.createModel([%{sign: ?-, segment: "2X"}]) == %{a: 0, b: -2, c: 0, error: []}
    assert EqParser.createModel([%{sign: ?-, segment: "2"}]) == %{a: 0, b: 0, c: -2, error: []}

    assert EqParser.createModel([%{sign: ?-, segment: "2.3"}]) == %{
             a: 0,
             b: 0,
             c: -2.3,
             error: []
           }

    assert EqParser.createModel([
             %{sign: ?-, segment: "2"},
             %{sign: ?+, segment: "2X2"},
             %{sign: ?-, segment: "2"},
             %{sign: ?+, segment: "2X^0"}
           ]) == %{a: 2, b: 0, c: -2, error: []}

    assert EqParser.createModel([
             %{sign: ?-, segment: "2x2"},
             %{sign: ?+, segment: "-21X"}
           ]) == %{a: -2, b: -21, c: 0, error: []}

    assert EqParser.createModel([
             %{sign: ?-, segment: "2"},
             %{sign: ?+, segment: "2X2"},
             %{sign: ?-, segment: "2X"},
             %{sign: ?+, segment: "902X2"},
             %{sign: ?+, segment: "-2X2"},
             %{sign: ?+, segment: "2X^0"},
             %{sign: ?-, segment: "7X^1"}
           ]) == %{a: 902, b: -9, c: 0, error: []}
  end
end
