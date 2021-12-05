#! /usr/bin/env elixir

input_stream = fn path ->
  path
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Stream.map(&String.to_integer/1)
end

count_depth_increases = fn list ->
  list
  |> Enum.chunk_every(2, 1, :discard)
  |> Enum.map(fn
    [a, b] when a < b -> 1
    _ -> 0
  end)
  |> Enum.sum()
end

part1 = fn stream ->
  stream
  |> count_depth_increases.()
end

part2 = fn stream ->
  stream
  |> Enum.chunk_every(3, 1, :discard)
  |> Enum.map(&Enum.sum/1)
  |> count_depth_increases.()
end

System.argv()
|> hd()
|> input_stream.()
|> part1.()
|> IO.inspect(label: "Part1")

System.argv()
|> hd()
|> input_stream.()
|> part2.()
|> IO.inspect(label: "Part2")
