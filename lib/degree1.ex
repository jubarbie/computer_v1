defmodule Degree1 do
  def resolve(%{1 => a, 0 => b}) do
    [a: a, b: b] |> solution
  end

  def resolve(_), do: {:error, %{message: "Bad argument given to degree 1 resolve"}}

  def solution(a: a, b: b) do
    {:ok, {:one, [a: a, b: b, x: b / -a]}}
  end

  def solution(_), do: {:error, %{message: "Bad argument given to degree 1 solution"}}
end
