defmodule Degree1 do
  def resolve(e) do
    e |> solution
  end
   
  def solution([a: a, b: b]) do
    {:one, [a: a, b: b, x: b/2]}
  end
  
end
