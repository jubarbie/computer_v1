defmodule MyMath do
  def sqrt(a) when a < 0 do
    raise "Square root of a negative number doesn't exist"
  end

  def sqrt(a) when a == 0 or a == 1, do: a

  def sqrt(a) do
    case a |> trunc |> is_pure do
      {:ok, s} -> if has_dec?(a), do: sqrt(a, s, 2), else: s
      {:nok, s} -> sqrt(a, s, 2)
    end
  end

  def sqrt(a, x, i) when i >= 0 do
    sqrt(a, 0.5 * (x + a / x), i - 1)
  end

  def sqrt(_, x, i) when i < 0, do: x

  def is_pure(a), do: is_pure(a, 1)

  def is_pure(a, x) do
    y = div(x * x + a, 2 * x)

    if absolute(y - x) < 2 do
      if is_sqrt?(a, y) do
        {:ok, y}
      else
        {:nok, y}
      end
    else
      is_pure(a, y)
    end
  end

  def is_sqrt?(a, b) when a >= 0, do: b * b == a

  def absolute(a) when a < 0, do: -a

  def absolute(a), do: a

  def has_dec?(a), do: a - trunc(a) != 0

  def max(a, b) when a > b, do: a
  def max(a, b) when a <= b, do: b

  def min(a, b) when a > b, do: b
  def min(a, b) when a <= b, do: a

  def find_irreductible(%{a: a, b: b}) when abs(a) == abs(b), do: {:ok, {:num, trunc(a / b)}}
  def find_irreductible(%{a: a, b: b}) when a - trunc(a) != 0 or b - trunc(b) != 0, do: {:error, {:message, "numbers must be intergers"}}
  def find_irreductible(%{a: a, b: b}) when rem(trunc(a), trunc(b)) == 0, do: {:ok, {:num, div(trunc(a), trunc(b))}}
  def find_irreductible(%{a: a, b: b}) do
    g = gcd(trunc(a), trunc(b))
    {:ok, {:frac, %{a: div(trunc(a), g), b: div(trunc(b), g)}}}
  end
  def gcd(a, b) when abs(a) == abs(b), do: abs(a) 
  def gcd(a, b) when abs(a) < abs(b), do: gcd(abs(b), abs(a))
  def gcd(a, b) when b == 0, do: abs(a)
  def gcd(a, b) do
    gcd(abs(b), rem(abs(a), abs(b)))
  end

  def is_whole?(n), do: n - trunc(n) == 0
end
