defmodule ComputerV1 do
  def display({nb_sol, res}, prec, verb, frac) do
    result = Enum.map(res, fn {k, v} -> {k, Float.round(v/1, prec)} end)
    degree = cond do
      result |> List.keymember?(:c, 0) -> 2
      result |> List.keymember?(:b, 0) -> 1
      true  -> 0
    end
    verbose("Verbose mode on", verb)
    verbose("#{prec} decimals precision", verb)
    case degree do
      2 ->
        IO.puts(
          "Reduced form: \e[33m#{result[:c]} * X^0 + #{result[:b]} * X^1 + #{result[:a]} * X^2 = 0\e[0m"
        )
        verbose("Natural form: \e[33m#{result[:a]}x\xc2\xb2 + #{result[:b]}x + #{result[:c]} = 0", verb)
        verbose("a: #{result[:a]}\nb: #{result[:b]}\nc: #{result[:c]}", verb)
        IO.puts("Polynominal degree: \e[33m2\e[0m")
        verbose("Discriminant formula: b^2 - 4ac", verb)
        verbose("#{result[:b]}^2 - 4 * #{result[:a]} * #{result[:c]}", verb)
        IO.puts("Disciminant: \e[33m#{result[:delta]}\e[0m")
        case result[:delta] do
          x when x == 0 -> verbose("Discriminant is null", verb)
          x when x > 0 -> verbose("Discriminant is positive", verb)
          x when x < 0 -> verbose("Discriminant is negative", verb)
        end
      1 ->
        IO.puts("Reduced form: \e[33m#{result[:b]} * X^0 + #{result[:a]} * X^1 = 0\e[0m")
        verbose("Natural form: \e[33m#{result[:a]}x + #{result[:b]} = 0", verb)
        IO.puts("Polynominal degree: \e[33m1\e[0m")

      0 ->
        IO.puts("Reduced form: \e[33m#{result[:a]} = 0\e[0m")
        IO.puts("Polynominal degree: \e[33m0\e[0m")
    end

    case nb_sol do
      :nosol ->
        IO.puts("\e[31mThe equation has no solution\e[0m")

      :one ->
        IO.puts("The equation has one solution: \e[32m#{result[:x]}\e[0m")

      :two ->
        IO.puts("The equation has two solutions:")
        IO.puts("\t• #{-result[:b]} - √#{fraction(result[:delta], 2 * result[:a], frac)} = \e[32m#{result[:x1]}\e[0m")
        IO.puts("\t• #{-result[:b]} + √#{fraction(result[:delta], 2 * result[:a], frac)} = \e[32m#{result[:x2]}\e[0m")

      :im ->
        IO.puts("The equation has 2 complex solutions:")
        verbose("Irreductible fraction: -#{result[:b]} - √#{result[:delta]}/#{2 * result[:a]}", verb)
        IO.puts("\t• \e[32m#{fraction(result[:b], 2 * result[:a], frac)} + i * √#{fraction(-result[:delta], 2 * result[:a], frac)}\e[0m")
        IO.puts("\t• \e[32m#{fraction(result[:b], 2 * result[:a], frac)} - i * √#{fraction(-result[:delta], 2 * result[:a], frac)}\e[0m")

      :all ->
        IO.puts("\e[32mAll real numbers are solution\e[0m")
    end
  end

  def fraction(a, b, frac) when frac do
    case MyMath.find_irreductible(%{a: a, b: b}) do
      {:error, _} -> "#{a}/#{b}"
      {:ok, {:num, n}} -> "#{n}"
      {:ok, {:frac, %{a: na, b: nb}}} -> "#{na}/#{nb}"
    end
  end

  def fraction(a, b, _frac), do: "#{a}/#{b}"

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
      OptionParser.parse(
        args,
        strict: [
          precision: :integer,
          verbose: :boolean,
          help: :boolean,
          equation: :string,
          fraction: :boolean
        ],
        aliases: [
          p: :precision,
          v: :verbose,
          h: :help,
          e: :equation,
          f: :fraction
        ]
      )
    
    if List.keymember?(opts, :precision, 0) && (opts[:precision] < 0 || opts[:precision] > 15) do
      usage()
      System.halt(0)
    end

    if List.keymember?(opts, :help, 0) do
      help()
      System.halt(0)
    end

    if List.keymember?(opts, :equation, 0) do
      {opts, [opts[:equation] | params]}
    else
      {opts, params}
    end
    
  end

  defp response({opts, params}) do
    case length(params) do
      1 ->
        List.first(params)
        |> EqParser.fromString()
        |> ErrorHandler.checkResult()
        |> ComputerV1.dispatchResolution()
        |> ErrorHandler.checkResult()
        |> ComputerV1.display(opts[:precision] || 5, opts[:verbose], opts[:fraction])

      _ ->
        usage()
    end

    System.halt(0)
  end

  defp usage() do
    IO.puts("usage: computer_v1 [-efhpv] equation")
  end

  defp help() do
    IO.puts("\e[1mNAME\e[0m")
    IO.puts("\tcomputer_v1 \e[90m-- Equation solver up to degree 2\e[0m")
    IO.puts("")
    IO.puts("\e[1mSYNOPSIS\e[0m")
    IO.puts("\tcomputer_v1 \e[90m[\e[0m-ehpv\e[90m] equation\e[0m")
    IO.puts("")
    IO.puts("\e[1mDESCRIPTION\e[0m")
    IO.puts("\tcomputer_v1\e[90m is an equation solver able to solve up to degree 2 equations\e[0m")
    IO.puts("\t\e[90mThe equation given as a string can be written in many different forms, see exemples below\e[0m")
    IO.puts("\t-e\e[90m\tEquation to solve, usefull when the equation starts with a '-'\e[0m")
    IO.puts("\t-f\e[90m\tForce the display of irreductible fraction when relevant\e[0m")
    IO.puts("\t-h\e[90m\tHelp\e[0m")
    IO.puts("\t-p\e[90m\tPrecision, number of decimals (from 1 to 15)\e[0m")
    IO.puts("\t-v\e[90m\tVerbose mode\e[0m")
    IO.puts("")
    IO.puts("\e[1mEXAMPLES\e[0m")
    IO.puts("\t\e[90mcomputer_v1 \"3 * X^2 + 2 * X + 1 = 0\"\e[0m")
    IO.puts("\t\e[90mcomputer_v1 \"3X^2 + 2X + 1 = 0\"\e[0m")
    IO.puts("\t\e[90mcomputer_v1 \"3X2 + 2X + 1 = 0\"\e[0m")
    IO.puts("\t\e[90mcomputer_v1 \"3X2+2X+1=0\"\e[0m")
    IO.puts("\t\e[90mcomputer_v1 -e=\"-3X2+2X+1=0\"\e[0m")
  end
end
