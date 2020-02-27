defmodule EqParser do
  def parseABC(str) do
    # Removing all spaces
    eq = str |> String.replace(~r/\s+/, "") |> String.split("=")

    IO.puts(eq)
    regex = ~r/(?<a>[+-]?\d*(\*)?x(\^)?2)/i

    captured = Regex.named_captures(regex, eq, capture: :all, global: true)

    # captured
    #   Map.merge(
    #     %{"a" => "0", "b" => "0", "c" => "0"},
    #     Regex.named_captures(regex, eq, capture: :all_names, global: true)
    #   )

    # parsed = parseABCtoInt(captured)
    IO.inspect(captured)

    # IO.inspect(parsed)

    case captured |> parseABCtoInt do
      [{a, ""}, {b, ""}, {c, ""}] -> {:ok, %{a: a, b: b, c: c}}
      [{b, ""}, {c, ""}] -> {:ok, %{a: b, b: c}}
      [{c, ""}] -> {:ok, %{a: c}}
      err -> err
    end
  end

  def parseABCtoInt(%{"a" => a, "b" => b, "c" => c}) do
    Enum.map([a, b, c], fn e -> parseNb(e) end)
  end

  def parseABCtoInt(i) do
    IO.inspect(i)
    {:error, "Malformed equation"}
  end

  def parseNb("") do
    Integer.parse("1")
  end

  def parseNb(nb) do
    Integer.parse(nb)
  end
end
