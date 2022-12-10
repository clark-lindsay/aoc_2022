File.stream!(Path.relative("input.txt"))
|> Stream.map(&String.trim/1)
|> Stream.filter(&(String.length(&1) > 0))
|> Task.async_stream(fn pair ->
  [[start_a, end_a], [start_b, end_b]] =
    String.split(pair, ",")
    |> Enum.map(fn assignment ->
      String.split(assignment, "-")
      |> Enum.map(&String.to_integer/1)
    end)

  set_a = MapSet.new(start_a..end_a)
  set_b = MapSet.new(start_b..end_b)

  !MapSet.disjoint?(set_a, set_b)
end)
|> Enum.count(fn {:ok, bool} -> bool end)
|> IO.inspect(label: "result")
