defmodule EqParser do
  def fromString(str) do
    # Removing all spaces and double signs
    str
    |> String.replace(~r/\s+/, "")
    |> String.replace(["+-","-+"], "-")
    |> String.replace(",", ".")
    |> String.split("=")
    |> parseEquation
  end

  def addDegrees(model, degree) do
    0..degree
    |> Enum.map(fn d -> {d, 0} end)
    |> Map.new()
    |> Map.merge(model)
  end

  def parseEquation([_left, _right] = s) do
    case Enum.map(s, &parseOperations/1) do
      [
        ok: leftSeg,
        ok: rightSeg
      ] ->
        case Enum.map([leftSeg, rightSeg], &createModel/1) do
          [{:ok, l}, {:ok, r}] ->
            degreeLeft = l |> ComputerV1.getEquationDegree()
            degreeRight = r |> ComputerV1.getEquationDegree()
            degree = MyMath.max(degreeLeft, degreeRight)
            left = addDegrees(l, degree)
            right = addDegrees(r, degree)
            merged = Map.merge(left, right, &mergeSides/3)
            {:ok, merged}

          _ ->
            {:error, %{message: "Parsing error"}}
        end

      _ ->
        {:error, %{message: "Parsing error"}}
    end
  end

  def parseEquation(d), do: {:error, %{message: "Equation must have 2 sides", data: d}}
  
  def mergeSides(_k, v1, v2) do
    v1 - v2
  end

  def createModel(ops) do
    l = Enum.map(ops, &parseSegment/1)

    if List.keymember?(l, :error, 0) do
      {:error, %{message: "Error while parsing"}}
    else
      l |> flatSegments
    end
  end

  def flatSegments(l) do
    errors = Enum.filter(l, fn x -> elem(x, 0) == :error end)

    if length(errors) > 0 do
      {:error, %{message: "Error while parsing"}}
    else
      flat =
        l
        |> Enum.filter(fn x -> elem(x, 0) == :ok end)
        |> Enum.map(fn x -> elem(x, 1) end)
        |> Enum.reduce(fn x, acc ->
          Map.merge(x, acc, fn _k, v1, v2 ->
            v1 + v2
          end)
        end)

      {:ok, flat}
    end
  end

  def parseSegment(%{sign: sign, segment: seg}) do
    regx = ~r/^((?<coeff>[+-]?\d*(\.\d*)?)((\*)?(?<x>X)((\^)?(?<degree>\d{1,5}))?)?)$/i

    capture = Regex.named_captures(regx, seg, capture: :all_names)
    case capture do
      %{"coeff" => coeff, "degree" => degree, "x" => x} -> getNumber(x, degree, sign, coeff)
      _ -> {:error, %{message: "Error while parsing equation: " <> seg}}
    end
  end

  def getNumber(x, degree, sign, coeff) do
    degree =
      if degree == "" do
        if x == "", do: "0", else: "1"
      else
        degree
      end

    coeff = if coeff == "", do: "1", else: coeff

    case [Float.parse(coeff), Integer.parse(degree)] do
      [{i, ""}, {j, ""}] ->
        if sign == ?-, do: {:ok, %{j => i * -1}}, else: {:ok, %{j => i}}

      _ ->
        :error
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
