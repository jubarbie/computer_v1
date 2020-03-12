defmodule ComputerV1 do
  def display({nb_sol, result}, prec) do
    cond do
      result |> List.keymember?(:c, 0) ->
        IO.puts(
          "Reduced form: #{result[:c]} * X^0 + #{result[:b]} * X^1 + #{result[:a]} * X^2 = 0"
        )

        IO.puts("Polynominal degree: 2")
        IO.puts("Disciminant: #{result[:delta] |> Float.round(prec)}")

      result |> List.keymember?(:b, 0) ->
        IO.puts("Reduced form: #{result[:b]} * X^0 + #{result[:a]} * X^1 = 0")
        IO.puts("Polynominal degree: 1")

      true ->
        IO.puts("Polynominal degree: 0")
    end

    case nb_sol do
      :nosol ->
        IO.puts("The equation has no solution")

      :one ->
        IO.puts("The equation has one solution: #{result[:x] |> Float.round(prec)}")

      :two ->
        IO.puts(
          "The equation has two solutions: #{result[:x1] |> Float.round(prec)} & #{
            result[:x2] |> Float.round(prec)
          }"
        )

      :all ->
        IO.puts("The equation has an infinite number of solutions")
    end
  end

  def dispatchResolution(%{a: a, b: b, c: c}) when a == 0 and b == 0, do: Degree0.resolve(%{a: c})
  def dispatchResolution(%{a: a, b: b, c: c}) when a == 0, do: Degree1.resolve(%{a: b, b: c})
  def dispatchResolution(%{a: _, b: _, c: _} = e), do: Degree2.resolve(e)
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

    if opts[:precision] < 0 || opts[:precision] > 15 do
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
        |> ComputerV1.display(opts[:precision] || 5)

      _ ->
        usage()
    end

    System.halt(0)
  end

  defp usage() do
    IO.puts("usage: computer_v1 [-p precision (0..15)] [equation]")
  end
end
