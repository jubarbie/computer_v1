defmodule MyMathTest do
  use ExUnit.Case

  test "First pure roots (0, 1, 4, 9, 16)" do
    assert MyMath.is_pure(0) == {:ok, 0}
    assert MyMath.is_pure(1) == {:ok, 1}
    assert MyMath.is_pure(4) == {:ok, 2}
    assert MyMath.is_pure(9) == {:ok, 3}
    assert MyMath.is_pure(16) == {:ok, 4}
  end
 
  test "Squre root 103" do
    a = MyMath.sqrt(103) |> Float.ceil(5)
    b = :math.sqrt(103) |> Float.ceil(5)
    assert a == b
  end

  test "Negative square root" do
    assert_raise RuntimeError, "Square root of a negative number doesn't exist", fn -> 
      MyMath.sqrt -2
    end
  end

  test "Square root 10.32" do
    a = MyMath.sqrt(10.32) |> Float.ceil(5)
    b = :math.sqrt(10.32) |> Float.ceil(5)
    assert a == b
  end
  
  test "Square root 10212.003342" do
    a = MyMath.sqrt(10212.003342) |> Float.ceil(5)
    b = :math.sqrt(10212.003342) |> Float.ceil(5)
    assert a == b
  end


end
