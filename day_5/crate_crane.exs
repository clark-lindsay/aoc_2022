[_crates_in_a_syntax_i_dont_want_to_parse, crane_operations, _eof] =
  File.read!(Path.relative("input.txt"))
  |> String.split("\n\n")

initial_crates = %{
  1 => ~w(Z V T B J G R),
  2 => ~w(L V R J),
  3 => ~w(F Q S),
  4 => ~w(G Q V F L N H Z),
  5 => ~w(W M S C J T Q R),
  6 => ~w(F H C T W S),
  7 => ~w(J N F V C Z D),
  8 => ~w(Q F R W D Z G L),
  9 => ~w(P V W B J)
}

crane_operations
|> String.split("\n")
|> Enum.map(fn operation ->
  Regex.named_captures(
    ~r/[\w]+\s(?<count>\d+)\s[\w]+\s(?<from>\d+)\s[\w]+\s(?<to>\d+)/,
    operation
  )
end)
|> Enum.reduce(initial_crates, fn %{"count" => count, "from" => from, "to" => to}, crates ->
  {to_move, to_leave} =
    crates[String.to_integer(from)]
    |> Enum.split(String.to_integer(count))

  crates
  |> Map.put(String.to_integer(from), to_leave)
  |> Map.update!(String.to_integer(to), fn stack -> to_move ++ stack end)
end)
|> IO.inspect(label: "result")
