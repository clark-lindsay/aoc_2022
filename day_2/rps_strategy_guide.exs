# following the elf's strategy guide when they have only explained the 
# first column of the "guide" input to us

File.read!(Path.relative_to_cwd("input.txt"))
|> String.split("\n")
|> Enum.filter(&(String.length(&1) > 0))
|> Enum.reduce(0, fn player_choices, acc ->
  [opponent_choice, response_choice] = String.split(player_choices)

  opponent_choice =
    case opponent_choice do
      "A" -> :rock
      "B" -> :paper
      "C" -> :scissors
    end

  response_choice =
    case response_choice do
      "X" -> :rock
      "Y" -> :paper
      "Z" -> :scissors
    end

  response_bonus =
    case response_choice do
      :rock -> 1
      :paper -> 2
      :scissors -> 3
    end

  outcome_value =
    case [opponent_choice, response_choice] do
      [same_choice, same_choice] -> 3
      [:rock, :paper] -> 6
      [:paper, :scissors] -> 6
      [:scissors, :rock] -> 6
      _ -> 0
    end

  acc + response_bonus + outcome_value
end)
|> IO.inspect(label: "result")
