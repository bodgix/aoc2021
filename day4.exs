defmodule Bingo do
  defmodule Board do
    defstruct numbers: %{}, hits: %{}, width: nil, height: nil, winner: false

    def parse(lines) when is_list(lines) do
      board = %__MODULE__{height: Enum.count(lines)}

      lines
      |> Enum.with_index()
      |> Enum.reduce(board, &parse_line/2)
    end

    def update_board(%__MODULE__{numbers: numbers} = board, number) do
      hit = Map.get(numbers, number)

      update_hits(board, hit)
      |> check_winner(hit)
    end

    def unmarked_numbers(%__MODULE__{numbers: numbers, hits: hits} = _board) do
      numbers
      |> Map.to_list()
      |> Enum.filter(fn
        {{_x, _y} = coords, _val} -> Map.get(hits, coords) == nil
        _ -> false
      end)
      |> Enum.map(fn {_coord, val} -> val end)
    end

    defp update_hits(%__MODULE__{} = board, nil), do: board

    defp update_hits(%__MODULE__{} = board, hit),
      do: %{board | hits: Map.put(board.hits, hit, true)}

    defp check_winner(board, nil), do: board

    defp check_winner(%__MODULE__{width: width, height: height, hits: hits} = board, {row, col}) do
      line_hits =
        0..width
        |> Enum.map(&Map.get(hits, {row, &1}))
        |> Enum.filter(&(&1 != nil))
        |> Enum.count()

      col_hits =
        0..height
        |> Enum.map(&Map.get(hits, {&1, col}))
        |> Enum.filter(&(&1 != nil))
        |> Enum.count()

      %{board | winner: line_hits == width || col_hits == height}
    end

    defp parse_line({line, row_num}, %{numbers: numbers} = board) do
      line_list = String.split(line)

      new_numbers =
        line_list
        |> Enum.map(&String.to_integer/1)
        |> Enum.with_index()
        |> Enum.reduce(numbers, fn {val, col}, acc ->
          Map.put(acc, val, {row_num, col})
          |> Map.put({row_num, col}, val)
        end)

      %{board | numbers: new_numbers, width: Enum.count(line_list)}
    end
  end

  defstruct boards: [], numbers: [], winning_board: [], last_number: nil

  alias __MODULE__.Board

  def parse([numbers_line, "" | rest] = _input) do
    numbers = parse_numbers(numbers_line)
    boards = parse_boards(rest)
    %__MODULE__{numbers: numbers, boards: boards}
  end

  def parse_numbers(numbers_line) do
    numbers_line
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def parse_boards(lines) do
    lines
    |> Enum.chunk_by(fn
      "" -> :separator
      _ -> :line
    end)
    |> Enum.filter(&(&1 != [""]))
    |> Enum.map(&Board.parse/1)
  end

  def play(%__MODULE__{winning_board: [], numbers: [number | rest]} = bingo) do
    new_bingo =
      update_boards(bingo, number)
      |> check_winner()

    play(%{new_bingo | numbers: rest, last_number: number})
  end

  def play(bingo), do: bingo

  defp update_boards(%__MODULE__{boards: boards} = bingo, number) do
    new_boards =
      boards
      |> Enum.map(&Board.update_board(&1, number))

    %{bingo | boards: new_boards}
  end

  defp check_winner(%__MODULE__{boards: boards} = bingo) do
    %{bingo | winning_board: [boards |> Enum.filter(& &1.winner) | bingo.winning_board], boards: boards |> Enum.filter(&(!&1.winner))}
  end
end

bingo =
  System.argv()
  |> hd()
  |> File.read!()
  |> String.split("\n")
  |> Enum.map(&String.trim/1)
  |> Bingo.parse()
  |> Bingo.play()

bingo.winning_board
|> hd()
|> Bingo.Board.unmarked_numbers()
|> Enum.sum()
|> Kernel.*(bingo.last_number)
|> IO.puts()
