defmodule Degree1 do
  def resolve(%{a: a, b: b} = e) do
    [a: a, b: b] |> solution
  end

  def resolve(_), do: {:error, %{message: "Bad argument given to degree 1 resolve"}}

  def solution(a: a, b: b) do
    {:ok, {:one, [a: a, b: b, x: b / 2]}}
  end

  def solution(_), do: {:error, %{message: "Bad argument given to degree 1 solution"}}
end
