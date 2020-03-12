defmodule EqParser do
  def fromString(str) do
    # Removing all spaces
    str
    |> String.replace(~r/\s+/, "")
    |> String.split("=")
    |> parseEquation
  end

  def parseEquation([left, right] = s) do
    case Enum.map(s, &parseOperations/1) do
      [
        ok: leftSeg,
        ok: rightSeg
      ] ->
        case Enum.map([leftSeg, rightSeg], &createModel/1) do
          [%{a: la, b: lb, c: lc}, %{a: ra, b: rb, c: rc}] ->
            {:ok, %{a: la - ra, b: lb - rb, c: lc - rc}}

          _ ->
            {:error, %{message: "Parsing error"}}
        end

      _ ->
        {:error, %{message: "Parsing error"}}
    end
  end

  def parseEquation(d), do: {:error, %{message: "Equation must have 2 sides", data: d}}

  def createModel(ops) do
    l = Enum.map(ops, &parseABC/1)

    if List.keymember?(l, :error, 0) do
      {:error, %{message: "Error white parsing"}}
    else
      l |> flatABC
    end
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
    regx = ~r/^((?<coeff>[+-]?\d*(\.\d*)?)(\*)?X(\^)?(?<degree>\d*))$/i

    capture = Regex.named_captures(regx, seg, capture: :all_names)
    IO.puts(captures)

    case capture do
      %{"coeff" => coeff, "degree" => degree} -> getNumber(:a, sign, a)
      [nil, %{"b" => b}, nil] -> getNumber(:b, sign, b)
      [nil, nil, %{"c" => c}] -> getNumber(:c, sign, c)
      _ -> {:error, %{message: "Error while parsing equation: " <> seg}}
    end
  end

  def getNumber(o, sign, "") do
    if sign == ?-, do: {:ok, %{o => -1}}, else: {:ok, %{o => 1}}
  end

  def getNumber(o, sign, nb) do
    case Float.parse(nb) do
      {i, ""} -> if sign == ?-, do: {:ok, %{o => i * -1}}, else: {:ok, %{o => i}}
      _ -> :error
    end
  end

  def parseOperations(""), do: {:error, %{message: "Empty string"}}

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
          {:error, %{message: "Multiple sign not supported"}}

        [?- | _] ->
          {:error, %{message: "Multiple sign not supported"}}

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
