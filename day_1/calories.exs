chunk_fun = fn calories, acc ->
  if String.length(calories) == 0 do
    {:cont, Enum.reverse(acc), []}
  else
    {:cont, [String.to_integer(calories) | acc]}
  end
end

after_fun = fn
  [] -> {:cont, []}
  acc -> {:cont, Enum.reverse(acc), []}
end

File.read!(Path.relative_to_cwd("input.txt"))
|> String.split("\n")
|> Stream.chunk_while([], chunk_fun, after_fun)
|> Stream.filter(&(length(&1) > 0))
|> Stream.map(&Enum.sum/1)
|> Enum.sort(:desc)
|> Enum.take(3)
|> Enum.sum()
|> IO.inspect(label: "Total calories held by top three elves")
