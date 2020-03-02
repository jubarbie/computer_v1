defmodule Degree2 do
  def resolve(e) do
    e |> discriminant |> solution
  end

  def discriminant(%{a: a, b: b, c: c}) do
    d = b * b - 4 * a * c
    [delta: d, a: a, b: b, c: c]
  end

  def solution(delta: delta, a: a, b: b, c: c) when delta > 0 do
    x1 = (-b - :math.sqrt(delta)) / (2 * a)
    x2 = (-b + :math.sqrt(delta)) / (2 * a)
    {:two, [delta: delta, a: a, b: b, c: c, x1: x1, x2: x2]}
  end

  def solution(delta: delta, a: a, b: b, c: c) when delta == 0 do
    x = -b / 2 * a
    {:one, [delta: delta, a: a, b: b, c: c, x: x]}
  end

  def solution(delta: delta, a: a, b: b, c: c) when delta < 0 do
    {:nosol, [delta: delta, a: a, b: b, c: c]}
  end
end
