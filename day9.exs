defmodule BottomMap do
  def parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {line, y}, acc ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.reduce(acc, fn {depth, x}, acc2 ->
        acc2
        |> Map.put({x, y}, String.to_integer(depth))
      end)
    end)
  end

  def adjacent(map, {x, y} = _coords) do
    for(
      x1 <- (x - 1)..(x + 1),
      y1 <- (y - 1)..(y + 1),
      x1 >= 0,
      y1 >= 0,
      x1 == x or y1 == y,
      !(x1 == x and y1 == y),
      do: Map.get(map, {x1, y1})
    )
    |> Enum.filter(&(&1 != nil))
  end

  def adjacent_coords(map, {x, y} = _coords) do
    for(
      x1 <- (x - 1)..(x + 1),
      y1 <- (y - 1)..(y + 1),
      x1 >= 0,
      y1 >= 0,
      x1 == x or y1 == y,
      !(x1 == x and y1 == y),
      do: {x1, y1}
    )
    |> Enum.filter(fn coords -> Map.get(map, coords) != nil end)
  end

  def low_points(map) do
    map
    |> Enum.to_list()
    |> Enum.map(fn {coords, height} ->
      lower_adjacent =
        adjacent(map, coords)
        |> Enum.reduce(0, fn
          adj_height, acc when adj_height <= height -> acc + 1
          _adj_height, acc -> acc
        end)

      {coords, height, lower_adjacent}
    end)
    |> Enum.filter(fn {_coords, _height, lower_adjacent} -> lower_adjacent == 0 end)
  end

  def find_basin(map, start_point) do
    find_basin(map, [start_point], MapSet.new(), MapSet.new())
  end

  def find_basin(_map, [], _visited, result), do: MapSet.to_list(result)

  def find_basin(map, [point | rest] = _point_queue, visited, result) do
    next_points =
      adjacent_coords(map, point)
      |> Enum.filter(fn adj_coords -> Map.get(map, adj_coords) > Map.get(map, point) end)

    next_set = MapSet.new(next_points)
    unvisited_next_points = MapSet.difference(next_set, visited) |> MapSet.to_list()

    find_basin(
      map,
      unvisited_next_points ++ rest,
      MapSet.put(visited, point),
      MapSet.put(result, point)
    )
  end
end

input =
  System.argv()
  |> hd()
  |> File.read!()

map =
  input
  |> BottomMap.parse()

low_points = BottomMap.low_points(map)

low_points
|> Enum.map(fn {_coords, height, _lower_adjacent} -> 1 + height end)
|> Enum.sum()
|> IO.inspect(label: "Part 1")

map_part2 =
  map
  |> Enum.filter(fn {_k, v} -> v != 9 end)
  |> Map.new()

low_points
|> Enum.map(fn {coords, _, _} -> coords end)
|> Enum.map(&BottomMap.find_basin(map_part2, &1))
|> Enum.map(&Enum.count/1)
|> Enum.sort()
|> Enum.reverse()
|> Enum.take(3)
|> Enum.reduce(1, &*/2)
|> IO.inspect(label: "Part 2")
