# following the elf's strategy guide when they have explained the
# complete meaning of the "code" of their "strategy guide"

rps_superiority_rules = %{
  rock: %{loses_to: :paper, ties: :rock, wins_against: :scissors},
  paper: %{loses_to: :scissors, ties: :paper, wins_against: :rock},
  scissors: %{loses_to: :rock, ties: :scissors, wins_against: :paper}
}

File.read!(Path.relative_to_cwd("input.txt"))
|> String.split("\n")
|> Enum.filter(&(String.length(&1) > 0))
|> Enum.reduce(0, fn player_choices, acc ->
  [opponent_choice, response_strategy] = String.split(player_choices)

  opponent_choice =
    case opponent_choice do
      "A" -> :rock
      "B" -> :paper
      "C" -> :scissors
    end

  # decoding the `response_strategy`:
  # X -> we want to *lose*
  # Y -> we want to *tie*
  # Z -> we want to *win*
  response_choice =
    case response_strategy do
      "X" -> rps_superiority_rules[opponent_choice][:wins_against]
      "Y" -> rps_superiority_rules[opponent_choice][:ties]
      "Z" -> rps_superiority_rules[opponent_choice][:loses_to]
    end

  response_bonus =
    case response_choice do
      :rock -> 1
      :paper -> 2
      :scissors -> 3
    end

  outcome_value =
    case {opponent_choice, response_choice} do
      {same_choice, same_choice} -> 3
      {:rock, :paper} -> 6
      {:paper, :scissors} -> 6
      {:scissors, :rock} -> 6
      _ -> 0
    end

  acc + response_bonus + outcome_value
end)
|> IO.inspect(label: "result")
