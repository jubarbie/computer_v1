defmodule ComputerV1 do

  def resolve(e) do
    e |> discriminant |> solution
  end
  
  def display({nb_sol, result}, prec) do
    IO.puts "#{result[:a]}x^2 + #{result[:b]}x + #{result[:c]} = 0"
    IO.puts "Disciminant: #{result[:delta] |> Float.round(prec)}"
    case nb_sol do
      :nosol -> IO.puts "The equation has no solution"
      :one -> IO.puts "The equation has one solution: #{result[:x] |> Float.round(prec)}"
      :two -> IO.puts "The equation has two solutions: #{result[:x1] |> Float.round(prec)} & #{result[:x2] |> Float.round(prec)}"
    end
  end

  def discriminant([a: a, b: b, c: c]) do
    d = (b * b) - (4 * a * c)
    [delta: d, a: a, b: b, c: c]
  end

  def solution([delta: delta, a: a, b: b, c: c]) when delta > 0 do
    x1 = (-b - (:math.sqrt delta)) / (2 * a)
    x2 = (-b + (:math.sqrt delta)) / (2 * a)
    {:two, [delta: delta, a: a, b: b, c: c, x1: x1, x2: x2]}
  end

  def solution([delta: delta, a: a, b: b, c: c]) when delta == 0 do
    x = -b / 2 * a
    {:one, [delta: delta, a: a, b: b, c: c, x: x]}
  end

  def solution([delta: delta, a: a, b: b, c: c]) when delta < 0 do
    {:nosol, [delta: delta, a: a, b: b, c: c]}
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
    {opts, params, _} =
    OptionParser.parse(args, switches: [precision: :integer], aliases: [p: :precision])
    {opts, params}
  end

  defp response({opts, coef}) do
    case length coef do
      3 -> [{a, _}, {b, _}, {c, _}] = Enum.map(coef, fn(co) -> Float.parse(co) end)
        [a: a, b: b, c: c] |> ComputerV1.resolve |> ComputerV1.display(opts[:precision] || 5)
      _ -> usage()
    end
    System.halt(0)
  end

  defp usage() do
    IO.puts "usage: computer_v1 [-p] a b c"
  end
end
