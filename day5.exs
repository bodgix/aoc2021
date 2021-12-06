#! /usr/bin/env elixir

defmodule Hydrothermal do
  defstruct grid: %{}, lines: []

  def parse(input, opts \\ []) when is_binary(input) do
    %__MODULE__{}
    |> parse_lines(input)
    |> filter_lines(Keyword.get(opts, :part, 1))
    |> draw_lines()
  end

  def dangerous_areas(%__MODULE__{} = map, overlap_count) do
    map.grid
    |> Map.to_list()
    |> Enum.filter(fn {_coords, count} -> count >= overlap_count end)
  end

  defp parse_lines(%__MODULE__{} = map, input) do
    %{
      map
      | lines:
          input
          |> String.split("\n")
          |> Enum.map(&String.trim/1)
          |> Enum.filter(&(&1 != ""))
          |> Enum.map(fn input_line ->
            Regex.named_captures(
              ~r/^(?<x1>\d+),(?<y1>\d+) -> (?<x2>\d+),(?<y2>\d+)/,
              input_line
            )
            |> Map.update!("x1", &String.to_integer/1)
            |> Map.update!("y1", &String.to_integer/1)
            |> Map.update!("x2", &String.to_integer/1)
            |> Map.update!("y2", &String.to_integer/1)
          end)
    }
  end

  defp filter_lines(%__MODULE__{} = map, 1) do
    %{
      map
      | lines:
          map.lines
          |> Enum.filter(
            &(Map.fetch!(&1, "x1") == Map.fetch!(&1, "x2") or
                Map.fetch!(&1, "y1") == Map.fetch!(&1, "y2"))
          )
    }
  end

  defp filter_lines(%__MODULE__{} = map, 2), do: map

  defp draw_lines(%__MODULE__{} = map) do
    %{
      map
      | grid:
          map.lines
          |> Enum.reduce(%{}, fn line, acc ->
            line
            |> points_for_line()
            |> Enum.reduce(acc, fn {_x, _y} = coords, acc2 ->
              Map.update(acc2, coords, 1, &(&1 + 1))
            end)
          end)
    }
  end

  defp points_for_line(%{"x1" => x1, "y1" => y1, "x2" => x2, "y2" => y2} = _vector)
       when x1 > x2 do
    points_for_line(%{"x1" => x2, "y1" => y2, "x2" => x1, "y2" => y1})
  end

  defp points_for_line(%{"x1" => x1, "y1" => y1, "x2" => _x2, "y2" => _y2} = vector) do
    {dx, dy} = get_delta(vector)

    0..vector_length(vector)
    |> Enum.map(fn point_num ->
      {x1 + point_num * dx, y1 + point_num * dy}
    end)
  end

  defp get_delta(%{"x1" => x1, "y1" => y1, "x2" => x2, "y2" => y2} = _vector)
       when x1 < x2 and y1 < y2,
       do: {1, 1}

  defp get_delta(%{"x1" => x1, "y1" => y1, "x2" => x2, "y2" => y2} = _vector)
       when x1 == x2 and y1 < y2,
       do: {0, 1}

  defp get_delta(%{"x1" => x1, "y1" => y1, "x2" => x2, "y2" => y2} = _vector)
       when x1 < x2 and y1 > y2,
       do: {1, -1}

  defp get_delta(%{"x1" => x1, "y1" => y1, "x2" => x2, "y2" => y2} = _vector)
       when x1 == x2 and y1 > y2,
       do: {0, -1}

  defp get_delta(%{"x1" => x1, "y1" => y1, "x2" => x2, "y2" => y2} = _vector)
       when x1 < x2 and y1 == y2,
       do: {1, 0}

  defp vector_length(%{"x1" => x1, "y1" => y1, "x2" => x2, "y2" => y2}) do
    (:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2))
    |> :math.sqrt()
    |> trunc()
  end
end

input =
  System.argv()
  |> hd()
  |> File.read!()

input
|> Hydrothermal.parse(part: 1)
|> Hydrothermal.dangerous_areas(2)
|> Enum.count()
|> IO.inspect(label: "Part 1")

input
|> Hydrothermal.parse(part: 2)
|> Hydrothermal.dangerous_areas(2)
|> Enum.count()
|> IO.inspect(label: "Part 2")
