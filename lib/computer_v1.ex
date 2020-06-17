defmodule ComputerV1 do
  def display({nb_sol, result}, prec, verb) do
    verbose("Verbose mode on", verb)
    verbose("#{prec} decimals precision", verb)
    cond do
      result |> List.keymember?(:c, 0) ->
        IO.puts(
          "Reduced form: \e[33m#{result[:c] |> Float.round(prec)} * X^0 + #{result[:b] |> Float.round(prec)} * X^1 + #{result[:a] |> Float.round(prec)} * X^2 = 0\e[0m"
        )
        verbose("Natural form: \e[33m#{result[:a] |> Float.round(prec)}x\xc2\xb2 + #{result[:b] |> Float.round(prec)}x + #{result[:c] |> Float.round(prec)} = 0", verb)
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
        verbose("Natural form: \e[33m#{result[:a] |> Float.round(prec)}x + #{result[:b] |> Float.round(prec)} = 0", verb)
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
      OptionParser.parse(args, strict: [precision: :integer, verbose: :boolean, help: :boolean], aliases: [p: :precision, v: :verbose, h: :help])
    
    if List.keymember?(opts, :precision, 0) && (opts[:precision] < 0 || opts[:precision] > 15) do
      usage()
      System.halt(0)
    end

    if List.keymember?(opts, :help, 0) do
      help()
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
    IO.puts("usage: computer_v1 [-hpv] equation")
  end

  defp help() do
    IO.puts("\e[1mNAME\e[0m")
    IO.puts("\tcomputer_v1 \e[37m-- Equation solver up to degree 2\e[0m")
    IO.puts("")
    IO.puts("\e[1mSYNOPSIS\e[0m")
    IO.puts("\tcomputer_v1 \e[37m[\e[0m-hpv\e[37m] equation\e[0m")
    IO.puts("")
    IO.puts("\e[1mDESCRIPTION\e[0m")
    IO.puts("\tcomputer_v1\e[37m is an equation solver able to solve up to degree 2 equation\e[0m")
    IO.puts("\t\e[37mThe equation given as a string can be written in many different forms, see exemples\e[0m")
    IO.puts("\t-h\e[37m\tHelp\e[0m")
    IO.puts("\t-p\e[37m\tSpecify a decimal precision (from 1 to 15)\e[0m")
    IO.puts("\t-v\e[37m\tVerbose mode\e[0m")
    IO.puts("")
    IO.puts("\e[1mEXAMPLES\e[0m")
    IO.puts("\t\e[37mcomputer_v1 \"3 * X^2 + 2 * X + 1 = 0\"\e[0m")
    IO.puts("\t\e[37mcomputer_v1 \"3X^2 + 2X + 1 = 0\"\e[0m")
    IO.puts("\t\e[37mcomputer_v1 \"3X2 + 2X + 1 = 0\"\e[0m")
    IO.puts("\t\e[37mcomputer_v1 \"3X2+2X+1=0\"\e[0m")
  end
end
