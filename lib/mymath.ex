defmodule MyMath do

  def sqrt(a) when a < 0 do
    raise "Square root of a negative number doesn't exist"
  end

  def sqrt(a) when a == 0 or a == 1, do: a

  def sqrt(a) do
    case a |> trunc |> is_pure do
      {:ok, s} -> s 
      {:nok, s} -> sqrt a, s, 2
    end
  end
  
  def sqrt(a, x, i) when i >= 0 do
    sqrt(a, 0.5 * (x + a / x), i - 1)
  end

  def sqrt(a, x, i) when i < 0, do: x

  def is_pure(a), do: is_pure(a, 1)

  def is_pure(a, x) do
    y = div (x*x + a), (2*x)
    if absolute(y - x) < 2 do
      (if is_sqrt? a, y do
        {:ok, y}
      else
        {:nok, y}
      end)
    else
      is_pure(a, y)
    end
  end

  def is_sqrt?(a, b) when a >= 0, do: (b*b == a)

  def absolute(a) when a < 0, do: -a

  def absolute(a), do: a
end
