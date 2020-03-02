defmodule EqParser do
  def fromString(str) do
    # Removing all spaces
    str
    |> String.replace(~r/\s+/, "")
    |> String.split("=")
    |> parseEquation
  end

  def parseEquation([left, right]) do
    case Enum.map([left, right], &parseOperations/1) do
      [
        ok: leftSeg,
        ok: rightSeg
      ] ->
        case Enum.map([leftSeg, rightSeg], fn x ->
               x |> Enum.map(&parseABC/1) |> flatABC
             end) do
          [%{a: la, b: lb, c: lc}, %{a: ra, b: rb, c: rc}] ->
            {:ok, %{a: la - ra, b: lb - rb, c: lc - rc}}

          _ ->
            {:error, [leftSeg, rightSeg]}
        end

      _ ->
        {:error, [left, right]}
    end
  end

  def parseEquation(_), do: :error

  def createModel(ops) do
    Enum.map(ops, &parseABC/1) |> flatABC
  end

  def flatABC(l) do
    Enum.reduce(l, %{a: 0, b: 0, c: 0, error: []}, fn x, acc ->
      case x do
        {:ok, %{a: v}} -> %{acc | a: acc[:a] + v}
        {:ok, %{b: v}} -> %{acc | b: acc[:b] + v}
        {:ok, %{c: v}} -> %{acc | c: acc[:c] + v}
        _ -> %{acc | error: acc[:error] ++ x}
      end
    end)
  end

  def parseABC(%{sign: sign, segment: seg}) do
    regexes = [
      ~r/^((?<a>[+-]?\d*)(\*)?X(\^)?2)$/i,
      ~r/^((?<b>[+-]?\d*)(\*)?X((\^)?1)?)$/i,
      ~r/^((?<c>[+-]?\d*)(\*)?(X(\^)?0)?)$/i
    ]

    captures = Enum.map(regexes, fn x -> Regex.named_captures(x, seg, capture: :all_names) end)

    case captures do
      [%{"a" => a}, nil, nil] -> getInteger(:a, sign, a)
      [nil, %{"b" => b}, nil] -> getInteger(:b, sign, b)
      [nil, nil, %{"c" => c}] -> getInteger(:c, sign, c)
      _ -> :error
    end
  end

  def getInteger(o, sign, "") do
    if sign == ?-, do: {:ok, %{o => -1}}, else: {:ok, %{o => 1}}
  end

  def getInteger(o, sign, nb) do
    IO.inspect(nb)

    case Float.parse(nb) do
      {i, ""} -> if sign == ?-, do: {:ok, %{o => i * -1.0}}, else: {:ok, %{o => i}}
      _ -> :error
    end
  end

  def parseOperations(str) do
    case str |> String.to_charlist() do
      [?- | rest] -> parseOperations([], ?-, rest, [])
      [?+ | rest] -> parseOperations([], ?+, rest, [])
      [h | rest] -> parseOperations([h], ?+, rest, [])
    end
  end

  def parseOperations(current, currSign, [], segments) do
    {:ok, segments ++ [%{sign: currSign, segment: to_string(current)}]}
  end

  def parseOperations(current, currSign, [head | rest], segments) do
    if head == ?+ || head == ?- do
      case rest do
        [?+ | _] ->
          {:error, "Multiple sign not supported"}

        [?- | _] ->
          {:error, "Multiple sign not supported"}

        _ ->
          parseOperations(
            [],
            head,
            rest,
            segments ++ [%{sign: currSign, segment: to_string(current)}]
          )
      end
    else
      parseOperations(current ++ [head], currSign, rest, segments)
    end
  end
end
