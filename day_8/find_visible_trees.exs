# visibility states:
#   - `:unchecked`
#   - `:visible`
#   - `:border_tree` -> always visible b/c it's at the edge of the forest
#   - `:not_visible`
#
# These indicate whether or not a tree is visible from outside the forest,
# based on its height and the height of surrounding trees.

input_file_path = Path.relative("input.txt")

forest_width =
  File.stream!(input_file_path)
  |> Stream.take(1)
  |> Enum.at(0)
  |> String.trim()
  |> String.length()

forest =
  File.read!(input_file_path)
  |> String.split()
  |> Enum.with_index()
  |> Enum.map(fn {row, row_index} ->
    row =
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {height, col_index} ->
        # grid is 100 x 100
        # trees at the edge are always visible

        visibility =
          cond do
            row_index == 0 or col_index == 0 -> :border_tree
            row_index == forest_width - 1 or col_index == forest_width - 1 -> :border_tree
            true -> :unchecked
          end

        {String.to_integer(height), col_index, visibility}
      end)

    {row, row_index}
  end)

# important that the trees are ordered based on the perspective of the comparison tree
# e.g. if you are "looking West", then a `line_of_trees` from the grid as given should be
# reversed, to mimic the POV of the tree you are "looking out from"
view_info_for_tree = fn line_of_trees, tree_height ->
  {tallest, view_distance, _} =
    Enum.reduce(line_of_trees, {0, 0, :unbroken_view}, fn {other_height, _, _},
                                                          {tallest, view_distance, view_status} ->
      tallest = Enum.max([tallest, other_height])

      {view_distance, view_status} =
        if view_status == :unbroken_view do
          cond do
            tree_height > other_height -> {view_distance + 1, view_status}
            true -> {view_distance + 1, :obstructed_view}
          end
        else
          {view_distance, :obstructed_view}
        end

      {tallest, view_distance, view_status}
    end)

  {tallest, view_distance}
end

forest
|> Task.async_stream(fn {row, row_index} ->
  Enum.map(row, fn {height, col_index, visibility} ->
    if visibility == :border_tree do
      {height, 0, visibility}
    else
      {west_of_tree, [_tree | east_of_tree]} = Enum.split(row, col_index)

      {tallest_west, view_distance_west} = view_info_for_tree.(Enum.reverse(west_of_tree), height)
      {tallest_east, view_distance_east} = view_info_for_tree.(east_of_tree, height)

      {north_of_tree, [_tree | south_of_tree]} =
        Enum.reduce(forest, [], fn {row, _index}, acc ->
          tree_in_vertical = Enum.at(row, col_index)

          [tree_in_vertical | acc]
        end)
        |> Enum.reverse()
        |> Enum.split(row_index)

      {tallest_north, view_distance_north} =
        view_info_for_tree.(Enum.reverse(north_of_tree), height)

      {tallest_south, view_distance_south} = view_info_for_tree.(south_of_tree, height)

      scenic_score_for_tree =
        view_distance_north * view_distance_south * view_distance_east * view_distance_west

      if height > Enum.min([tallest_north, tallest_south, tallest_east, tallest_west]) and
           visibility != :border_tree do
        {height, scenic_score_for_tree, :visible}
      else
        {height, scenic_score_for_tree, :not_visible}
      end
    end
  end)
end)
|> Enum.flat_map(fn {:ok, data} -> data end)
|> Enum.reduce(%{visible_tree_count: 0, max_scenic_score: 0}, fn {_height, scenic_score_for_tree,
                                                                  visibility},
                                                                 %{
                                                                   visible_tree_count:
                                                                     visible_tree_count,
                                                                   max_scenic_score:
                                                                     max_scenic_score
                                                                 } ->
  visible_tree_count =
    if visibility == :border_tree or visibility == :visible do
      visible_tree_count + 1
    else
      visible_tree_count
    end

  %{
    visible_tree_count: visible_tree_count,
    max_scenic_score: Enum.max([max_scenic_score, scenic_score_for_tree])
  }
end)
|> IO.inspect(label: "result")
