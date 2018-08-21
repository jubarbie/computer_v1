defmodule ComputerV1 do

  def resolve(e) do
    res = e |> delta |> solution
    case res do
      {:nosol} -> IO.puts "The equation has no solution"
      {:one, {x: x}} -> IO.puts "The equation has one solution: #{x}"
      {:two, {x1: x1, x2: x2}} -> IO.puts "The equation has two solutions: #{x1} & #{x2}"
    end
  end

  def delta({a: a, b: b, c: c}) do
    d = (b * b) - (4 * a * c)
    {delta: d, a: a, b: b, c: c}
  end

  def solution({delta: delta, a: a, b: b, c: c}) when delta > 0 do
    x1 = (-b - (Math.sqrt delta)) / 2 * a * b
    x2 = (-b + (Math.sqrt delta)) / 2 * a * b
    {:two, {x1: x1, x2: x2}}
  end

  def solution({delta: delta, a: a, b: b, c: c}) when delta == 0 do
    x = -b / 2 * a
    {:one, {x: x}}
  end

  def solution({delta: delta, a: a, b: b, c: c}) when delta < 0 do
    {:nosol}
  end
end

defmodule ComputerV1.CLI do
  def main(args \\ []) do
    args
    |> parse_args
    |> response
    |> IO.puts()
  end

  defp parse_args(args) do
    {opts, args, _} =
      args |>
    OptionParser.parse(args)
    {opts, args}
  end

  defp response({opts, coef}) do
    case length coef do
      3 -> [{a, _}, {b, _}, {c, _}] = Enum.map(coef, fn(co) -> Float.parse(co) end)
        ComputerV1.resolve {a: a, b: b, c: c}
      _ -> usage
    end
  end

  defp usage() do
    "usage: computer_v1 a b c"
  end
end
