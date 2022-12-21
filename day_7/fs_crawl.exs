max_disk_space = 7.0e7
min_disk_space_for_update = 3.0e7

Task.Supervisor.start_link(name: FSTaskSupervisor)

defmodule FileSystem do
  def file_size(file_system_description, file_name) do
    file_description = Map.fetch!(file_system_description, file_name)

    case file_description do
      %{file_size: file_size} ->
        String.to_integer(file_size)

      %MapSet{} = directory_contents ->
        MapSet.to_list(directory_contents)
        |> Enum.map(&file_size(file_system_description, &1))
        |> Enum.sum()
    end
  end

  def absolute_path_from_stack(dir_stack) do
    dir_stack
    |> Enum.take_while(&(&1 != "/"))
    |> Enum.reverse()
    |> Enum.join("/")
    |> then(fn
      "" -> "/"
      path -> "/#{path}"
    end)
  end
end

file_system_info =
  File.read!(Path.relative("input.txt"))
  |> String.split("\n")
  |> Enum.reduce(%{"dir_stack" => ["/"]}, fn output_line, acc ->
    case output_line do
      "$ cd /" ->
        Map.put(acc, "dir_stack", ["/"])

      "$ cd .." ->
        Map.update!(acc, "dir_stack", fn [_head | tail] ->
          if(length(tail) == 0, do: ["/"], else: tail)
        end)

      "$ cd " <> directory_to_open ->
        Map.put(acc, "dir_stack", [directory_to_open | Map.get(acc, "dir_stack")])

      "dir " <> dir_name ->
        dir_stack = Map.get(acc, "dir_stack")

        new_path = fn path_to_dir, file_name ->
          case path_to_dir do
            "" -> "/#{file_name}"
            "/" -> "/#{file_name}"
            path -> "#{path}/#{file_name}"
          end
        end

        absolute_path_to_parent = FileSystem.absolute_path_from_stack(dir_stack)

        absolute_dir_path = new_path.(absolute_path_to_parent, dir_name)

        Map.update(
          acc,
          absolute_path_to_parent,
          MapSet.new([absolute_dir_path]),
          &MapSet.put(&1, absolute_dir_path)
        )

      "$" <> _ls_command ->
        acc

      "" ->
        acc

      file_description ->
        [file_size, file_name] = String.split(file_description)
        dir_stack = Map.get(acc, "dir_stack")

        absolute_path_to_parent = FileSystem.absolute_path_from_stack(dir_stack)

        absolute_path =
          case absolute_path_to_parent do
            "" -> "/#{file_name}"
            "/" -> "/#{file_name}"
            path -> "#{path}/#{file_name}"
          end

        file_info = %{
          file_size: file_size,
          file_name: absolute_path
        }

        Map.put(acc, absolute_path, file_info)
        |> Map.update(
          absolute_path_to_parent,
          MapSet.new([absolute_path]),
          &MapSet.put(&1, absolute_path)
        )
    end
  end)

dirs_only =
  file_system_info
  |> Enum.filter(fn
    {_name, _file_description = %struct{}} -> struct == MapSet
    _ -> false
  end)

directory_sizes =
  Task.Supervisor.async_stream(
    FSTaskSupervisor,
    dirs_only,
    fn {dir_name, _directory_contents} ->
      size = FileSystem.file_size(file_system_info, dir_name)

      {dir_name, size}
    end
  )
  |> Enum.map(fn {:ok, val} -> val end)
  |> Map.new()

Enum.reduce(
  directory_sizes,
  0,
  fn {_dir_name, size}, acc ->
    if size > 100_000,
      do: acc,
      else: acc + size
  end
)
|> IO.inspect(label: "Sum of all directories whose size is <= 100K")

total_fs_size = Map.fetch!(directory_sizes, "/")

Enum.reduce(directory_sizes, total_fs_size, fn {_dir_name, size},
                                               smallest_dir_deletion_to_allow_update ->
  if max_disk_space - total_fs_size + size > min_disk_space_for_update and
       size < smallest_dir_deletion_to_allow_update do
    size
  else
    smallest_dir_deletion_to_allow_update
  end
end)
|> IO.inspect(label: "Size of smallest directory that can be deleted to make room for update")
