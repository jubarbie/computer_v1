defmodule Degree0 do
  def resolve(%{0 => a}), do: [a: a] |> solution

  def resolve(_), do: {:error, %{message: "Bad argument given to degree 0 resolve"}}

  def solution(a: a) when a == 0, do: {:ok, {:all, [a: a]}}

  def solution(a: a), do: {:ok, {:nosol, [a: a]}}
end
