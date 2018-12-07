defmodule EqParser do

  def parseABC(str) do
	eq = String.replace(str, ~r/ +/, "")
	regex = ~r/^(?<a>[+,-]?\d*)\*?X\^?2((?:<b>[+,-]\d*)\*?X(\^?1)?)?((?:<c>[+,-]\d+)(\*?X\^?0)?)?$/i
	case Regex.named_captures(regex, eq, [capture: :all_names]) |> parseABCtoInt do
		[{a, ""}, {b, ""}, {c, ""}] -> {:ok, %{a: a, b: b, c: c}}
		b -> b
		_ -> {:error, "Malformed equation"}
	end
  end

  def parseABCtoInt(%{"a" => a, _}) do
  	Enum.map [a, b, c], fn e -> Integer.parse e end
  end

  def parseABCtoInt(_) do
	IO.puts "Malformed equation"
	System.halt(0)
  end

end
