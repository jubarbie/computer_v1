defmodule MyMathTest do
  use ExUnit.Case

  test "First pure roots (0, 1, 4, 9, 16)" do
    assert MyMath.is_pure(0) == {:ok, 0}
    assert MyMath.is_pure(1) == {:ok, 1}
    assert MyMath.is_pure(4) == {:ok, 2}
    assert MyMath.is_pure(9) == {:ok, 3}
    assert MyMath.is_pure(16) == {:ok, 4}
  end

  test "Square root 103" do
    a = MyMath.sqrt(103) |> Float.ceil(5)
    b = :math.sqrt(103) |> Float.ceil(5)
    assert a == b
  end

  test "Negative square root" do
    assert_raise RuntimeError, "Square root of a negative number doesn't exist", fn ->
      MyMath.sqrt(-2)
    end
  end

  test "Square root 10.32" do
    a = MyMath.sqrt(10.32) |> Float.ceil(5)
    b = :math.sqrt(10.32) |> Float.ceil(5)
    assert a == b
  end

  test "Square root 16.32" do
    a = MyMath.sqrt(16.32) |> Float.ceil(5)
    b = :math.sqrt(16.32) |> Float.ceil(5)
    assert a == b
  end

  test "Square root 4.32" do
    a = MyMath.sqrt(4.32) |> Float.ceil(5)
    b = :math.sqrt(4.32) |> Float.ceil(5)
    assert a == b
  end

  test "Square root -4.32" do
    assert_raise RuntimeError, "Square root of a negative number doesn't exist", fn ->
      MyMath.sqrt(-4.32)
    end
  end

  test "Square root 10212.003342" do
    a = MyMath.sqrt(10212.003342) |> Float.ceil(5)
    b = :math.sqrt(10212.003342) |> Float.ceil(5)
    assert a == b
  end

  test "greatest common denominator" do
    assert MyMath.gcd(0, 0) == 0
    assert MyMath.gcd(1, 1) == 1
    assert MyMath.gcd(2, 2) == 2
    assert MyMath.gcd(5, 5) == 5
    assert MyMath.gcd(10, 5) == 5
    assert MyMath.gcd(3, 5) == 1
    assert MyMath.gcd(3, 15) == 3
    assert MyMath.gcd(5, 25) == 5
    assert MyMath.gcd(-100, 10) == 10
    assert MyMath.gcd(10608, 391) == 17
  end

  test "irreductible fraction" do
    assert {:error, _} = MyMath.find_irreductible(%{a: 2.3, b: 2})
    assert {:ok, {:num, 1}} = MyMath.find_irreductible(%{a: 2.0, b: 2})
    assert {:ok, {:num, -1}} = MyMath.find_irreductible(%{a: 2.32, b: -2.32})
    assert {:ok, {:num, 3}} = MyMath.find_irreductible(%{a: 9.0, b: 3.0})
    assert {:ok, {:frac, %{a: 23, b: 624}}} = MyMath.find_irreductible(%{a: 391, b: 10608})
  end
end
