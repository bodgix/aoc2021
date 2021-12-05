#! /usr/bin/env elixir

use Bitwise

defmodule Diagnostic do
  def input(file) when is_binary(file) do
    file
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&String.split(&1, "", trim: true))
  end
end

# gamma =
  columns =
  System.argv()
  |> hd()
  |> Diagnostic.input()
  |> Enum.zip()
  |> Enum.map(&Tuple.to_list/1)
  |> IO.inspect()

length = Enum.count(columns)

gamma =
  columns
  |> Enum.map(&Enum.frequencies/1)
  |> Enum.map(fn
    %{"0" => zeroes, "1" => ones} when zeroes > ones -> 0
    _ -> 1
  end)
  |> Enum.join()
  |> String.to_integer(2)

epsilon = bnot(gamma) |> IO.inspect()

# IO.puts("Part1: #{gamma * epsilon}")
