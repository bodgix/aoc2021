defmodule SyntaxChecker do
  @opening_brackets %{?) => ?(, ?] => ?[, ?} => ?{, ?> => ?<}
  @error_scores %{?) => 3, ?] => 57, ?} => 1197, ?> => 25137}
  @bracket_scores %{?( => 1, ?[ => 2, ?{ => 3, ?< => 4}

  defstruct incomplete: [], corrupt: [], input: nil, score1: 0, score2: 0

  def solve(input) when is_binary(input) do
    %__MODULE__{input: parse(input)}
    |> find_incomplete_and_corrupt()
    |> calculate_scores()
  end

  def find_incomplete_and_corrupt(%__MODULE__{input: input} = checker) when is_list(input) do
    input
    |> Enum.reduce(checker, fn line, acc ->
      check_line(line, [], acc)
    end)
  end

  def calculate_scores(%__MODULE__{} = checker) do
    %{
      checker
      | score1:
          checker.corrupt
          |> Enum.map(&Map.fetch!(@error_scores, &1))
          |> Enum.sum(),
        score2:
          checker.incomplete
          |> Enum.map(
            &Enum.reduce(&1, 0, fn bracket, acc ->
              acc * 5 + Map.fetch!(@bracket_scores, bracket)
            end)
          )
          |> Enum.sort()
          |> Enum.at(length(checker.incomplete) |> div(2))
    }
  end

  defp check_line("", [], %__MODULE__{} = checker), do: checker

  defp check_line("", brackets, %__MODULE__{} = checker),
    do: %{checker | incomplete: [brackets | checker.incomplete]}

  defp check_line(
         <<closing_bracket, rest::binary>>,
         [previous_opening | rest_brackets] = _brackets,
         %__MODULE__{} = checker
       )
       when closing_bracket in [?), ?], ?}, ?>] do
    case Map.fetch!(@opening_brackets, closing_bracket) do
      ^previous_opening -> check_line(rest, rest_brackets, checker)
      _ -> %{checker | corrupt: [closing_bracket | checker.corrupt]}
    end
  end

  defp check_line(<<opening_bracket, rest::binary>>, brackets, %__MODULE__{} = checker),
    do: check_line(rest, [opening_bracket | brackets], checker)

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
  end
end

System.argv()
|> hd()
|> File.read!()
|> SyntaxChecker.solve()
|> (fn %{score1: score1, score2: score2} ->
      IO.puts("Part1: #{score1}\nPart2: #{score2}")
    end).()
