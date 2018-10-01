defmodule EqParser do

  def parse(str) do
	tab = String.split str, "="
	case tab do
		[left, "0"] ->	extractABC left
		_ -> fn() 	->	IO.puts "Wrong equation format. Ex: a * X^2 + b * X + c = 0"
			 			System.halt(0)
		 				end
	end
	left = tab
    {:ok, b}
  end

  def extractABC str do
	  list = String.split str, "+"
	  Enum.group_by(list, [a: 0, b: 0, c: 0], fn elem -> elem )
  end

end
