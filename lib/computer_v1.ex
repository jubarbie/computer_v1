defmodule ComputerV1 do
  def display({nb_sol, result}, prec, verb) do
    verbose("Verbose mode on", verb)
    verbose("#{prec} decimals precision", verb)
    cond do
      result |> List.keymember?(:c, 0) ->
        IO.puts(
          "Reduced form: \e[33m#{result[:c] |> Float.round(prec)} * X^0 + #{result[:b] |> Float.round(prec)} * X^1 + #{result[:a] |> Float.round(prec)} * X^2 = 0\e[0m"
        )
        verbose("a: #{result[:a] |> Float.round(prec)}\nb: #{result[:b] |> Float.round(prec)}\nc: #{result[:c] |> Float.round(prec)}", verb)
        IO.puts("Polynominal degree: \e[33m2\e[0m")
        verbose("Discriminant formula: b^2 - 4ac", verb)
        verbose("#{result[:b] |> Float.round(prec)}^2 - 4 * #{result[:a] |> Float.round(prec)} * #{result[:c] |> Float.round(prec)}", verb)
        IO.puts("Disciminant: \e[33m#{result[:delta] |> Float.round(prec)}\e[0m")
        case result[:delta] do
          x when x == 0 -> verbose("Discriminant is null", verb)
          x when x > 0 -> verbose("Discriminant is positive", verb)
          x when x < 0 -> verbose("Discriminant is negative", verb)
        end
      result |> List.keymember?(:b, 0) ->
        IO.puts("Reduced form: \e[33m#{result[:b] |> Float.round(prec)} * X^0 + #{result[:a] |> Float.round(prec)} * X^1 = 0\e[0m")
        IO.puts("Polynominal degree: \e[33m1\e[0m")

      true ->
        IO.puts("Polynominal degree: \e[33m0\e[0m")
    end

    case nb_sol do
      :nosol ->
        IO.puts("\e[31mThe equation has no solution\e[0m")

      :one ->
        IO.puts("The equation has one solution: \e[32m#{result[:x] |> Float.round(prec)}\e[0m")

      :two ->
        IO.puts("The equation has two solutions:")
        IO.puts("\t• \e[32m#{result[:x1] |> Float.round(prec)}\e[0m")
        IO.puts("\t• \e[32m#{result[:x2] |> Float.round(prec)}\e[0m")

      :im ->
        IO.puts("The equation has 2 complex solutions:")
        IO.puts("\t• \e[32m#{(result[:b] / 2 * result[:a]) |> Float.round(prec)} + i * √#{-result[:delta] |> Float.round(prec)} / #{2 * result[:a] |> Float.round(prec)}\e[0m")
        IO.puts("\t• \e[32m#{(result[:b] / 2 * result[:a]) |> Float.round(prec)} - i * √#{-result[:delta] |> Float.round(prec)} / #{2 * result[:a] |> Float.round(prec)}\e[0m")

      :all ->
        IO.puts("\e[31mThe equation has an infinite number of solutions\e[0m")
    end
  end

  def verbose(say, v) when v, do: IO.puts("\e[94m#{say}\e[0m") 
  def verbose(_say, _v), do: {} 

  def getEquationDegree(model) do
    model
    |> Map.to_list()
    |> Enum.reduce(0, fn {k, v}, d -> if k > d && v != 0, do: k, else: d end)
  end

  def dispatchResolution(model) do
    case model |> getEquationDegree() do
      0 ->
        Degree0.resolve(model)

      1 ->
        Degree1.resolve(model)

      2 ->
        Degree2.resolve(model)

      i ->
        IO.puts("Polynominal degree: #{i}")
        IO.puts("I can't solve it")
        System.halt(0)
    end
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
      OptionParser.parse(args, strict: [precision: :integer, verbose: :boolean], aliases: [p: :precision, v: :verbose])
    
    if List.keymember?(opts, :precision, 0) && (opts[:precision] < 0 || opts[:precision] > 15) do
      usage()
      System.halt(0)
    end

    {opts, params}
  end

  defp response({opts, coef}) do
    case length(coef) do
      1 ->
        List.first(coef)
        |> EqParser.fromString()
        |> ErrorHandler.checkResult()
        |> ComputerV1.dispatchResolution()
        |> ErrorHandler.checkResult()
        |> ComputerV1.display(opts[:precision] || 5, opts[:verbose])

      _ ->
        usage()
    end

    System.halt(0)
  end

  defp usage() do
    IO.puts("usage: computer_v1 [-p precision (0..15)] equation")
  end
end
