File.stream!(Path.relative("input.txt"), [encoding: :utf8], 1024)
|> Stream.flat_map(&String.graphemes/1)
|> Stream.chunk_every(4, 1)
|> Enum.find_index(fn chars -> MapSet.new(chars) |> MapSet.size() == 4 end)
|> then(fn start_of_packet -> start_of_packet + 4 end)
|> IO.inspect(label: "result")
