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
|> Enum.chunk_every(3)
|> Task.async_stream(fn group_of_rucksacks ->
  [ruck_one, ruck_two, ruck_three] =
    group_of_rucksacks
    |> Enum.map(fn contents ->
      contents
      |> String.to_charlist()
      |> Enum.map(ascii_to_priority)
      |> MapSet.new()
    end)

  # find the _one_ item that is represented in the rucksack of each elf
  # in the group; this is their "badge" item
  badge_item_set =
    MapSet.intersection(ruck_one, ruck_two)
    |> MapSet.intersection(ruck_three)

  if MapSet.size(badge_item_set) != 1 do
    raise "Failed to find exactly one item that occurs in all 3 rucksacks for a group"
  else
    MapSet.to_list(badge_item_set) |> hd()
  end
end)
|> Enum.reduce(0, fn {:ok, priority}, acc -> acc + priority end)
|> IO.inspect(label: "result")
