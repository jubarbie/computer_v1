defmodule Degree2 do
  def resolve(%{2 => _a, 1 => _b, 0 => _c} = e) do
    e |> discriminant |> solution
  end

  def resolve(_) do
    {:error, %{message: "Bad argument given to degree 2 resolve"}}
  end

  def discriminant(%{2 => a, 1 => b, 0 => c}) do
    d = b * b - 4 * a * c
    [delta: d, a: a, b: b, c: c]
  end

  def solution(delta: delta, a: a, b: b, c: c) when delta > 0 do
    x1 = (-b - MyMath.sqrt(delta)) / (2 * a)
    x2 = (-b + MyMath.sqrt(delta)) / (2 * a)
    {:ok, {:two, [delta: delta, a: a, b: b, c: c, x1: x1, x2: x2]}}
  end

  def solution(delta: delta, a: a, b: b, c: c) when delta == 0 do
    x = -b / 2 * a
    {:ok, {:one, [delta: delta, a: a, b: b, c: c, x: x]}}
  end

  def solution(delta: delta, a: a, b: b, c: c) when delta < 0 do
    {:ok, {:im, [delta: delta, a: a, b: b, c: c]}}
  end

  def solution(_), do: {:error, %{message: "Bad argument given to degree 2 solution"}}
end
