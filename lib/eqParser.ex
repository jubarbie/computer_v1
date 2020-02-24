defmodule EqParser do
  def parseABC(str) do
    eq = String.replace(str, ~r/ +/, "")

    regex =
      ~r/^((?<a>( *)[+-]?( *)\d*( *))\*?( *)X( *)\^?( *)2)?((?<b>( *)[+-]( *)\d*( *))\*?( *)X( *)(\^?1)?( *))?((?<c>( *)[+-]( *)\d+)(\*?( *)X( *)\^?0)?)?$/i

    captured =
      Map.merge(
        %{"a" => "0", "b" => "0", "c" => "0"},
        Regex.named_captures(regex, eq, capture: :all_names)
      )

    parsed = parseABCtoInt(captured)
    IO.inspect(captured)
    IO.inspect(parsed)

    case captured |> parseABCtoInt do
      [{a, ""}, {b, ""}, {c, ""}] -> {:ok, %{a: a, b: b, c: c}}
      [{b, ""}, {c, ""}] -> {:ok, %{a: b, b: c}}
      [{c, ""}] -> {:ok, %{a: c}}
      _ -> {:error, "Malformed equation"}
    end
  end

  def parseABCtoInt(%{"a" => a, "b" => b, "c" => c}) do
    Enum.map([a, b, c], fn e -> parseNb(e) end)
  end

  def parseABCtoInt(i) do
    IO.inspect(i)
    IO.puts("Malformed equation")
    # System.halt(0)
  end

  def parseNb("") do
    Integer.parse("1")
  end

  def parseNb(nb) do
    Integer.parse(nb)
  end
end
