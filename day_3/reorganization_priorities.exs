ascii_to_priority = fn ascii_char ->
  # 'a' is `97` in ASCII
  if ascii_char >= 97 do
    ascii_char - 96
  else
    ascii_char - 38
  end
end

File.read!(Path.relative("input.txt"))
|> String.split()
|> Task.async_stream(fn rucksack_contents ->
  {compartment_one, compartment_two} =
    rucksack_contents
    |> String.to_charlist()
    |> Enum.map(ascii_to_priority)
    |> Enum.split(String.length(rucksack_contents) |> Integer.floor_div(2))

  compartment_one = MapSet.new(compartment_one)

  Enum.find(compartment_two, &MapSet.member?(compartment_one, &1))
end)
|> Enum.reduce(0, fn {:ok, priority}, acc -> acc + priority end)
|> IO.inspect(label: "result")
