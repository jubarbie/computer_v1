defmodule ErrorHandler do
  def checkResult({:ok, d}), do: d

  def checkResult({:error, %{message: m}}) do
    IO.puts("Error:")
    IO.puts(m)
    System.halt(0)
  end
end
