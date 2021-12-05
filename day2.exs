#!/usr/bin/env elixir

defmodule Submarine do
  def input_stream(file) do
    file
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.split/1)
    |> Stream.map(fn [direction, count] -> [direction, String.to_integer(count)] end)
  end

  # Rules for Part1
  def update_position(["forward", count], {horizontal, depth}), do: {horizontal+count, depth}
  def update_position(["up", count], {horizontal, depth}), do: {horizontal, depth-count}
  def update_position(["down", count], {horizontal, depth}), do: {horizontal, depth+count}

  # Rules for Part2
  def update_position(["forward", count], {horizontal, depth, aim}), do: {horizontal+count, depth+count*aim, aim}
  def update_position(["up", count], {horizontal, depth, aim}), do: {horizontal, depth, aim-count}
  def update_position(["down", count], {horizontal, depth, aim}), do: {horizontal, depth, aim+count}
end

[{0, 0}, {0, 0, 0}]
|> Enum.map(fn start_pos ->
  System.argv()
  |> hd()
  |> Submarine.input_stream()
  |> Enum.reduce(start_pos, &Submarine.update_position/2)
end)
|> Enum.with_index(1)
|> Enum.map(fn {tuple, part_number} ->
  result = elem(tuple, 0) * elem(tuple, 1)
  "Part #{part_number}: #{result}"
end)
|> Enum.map(&IO.puts/1)
