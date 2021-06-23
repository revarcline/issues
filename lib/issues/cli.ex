defmodule Issues.CLI do
  @default_count 4

  @moduledoc """
  Handle the command line parsing and the dispatch to
  the various functions that end up generating a
  table of the last _n_ issues in a github project
  """

  def run(argv) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be -h or --help, which returns help

  Otherwise it is a github user name, project name, and (optionally)
  the number of entries to format.

  Return a tuple of `{ user, project, count }`, or `:help` if help
  was given.
  """
  def parse_args(argv) do
    OptionParser.parse(argv,
      switches: [help: :boolean],
      aliases: [h: :help]
    )
    |> elem(1)
    |> args_to_internal_representation()
  end

  def args_to_internal_representation([user, project, count]) do
    {user, project, String.to_integer(count)}
  end

  def args_to_internal_representation([user, project]) do
    {user, project, @default_count}
  end

  def args_to_internal_representation(_) do
    :help
  end

  def process(:help) do
    IO.puts("""
    usage: issues <user> <project> [ count | #{@default_count} ]
    """)
  end

  def process([user, project, count]) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response()
    |> sort_into_descending_order()
    |> last(count)
    |> relevant_keys()
  end

  def decode_response({:ok, body}), do: body

  def decode_response({:error, error}) do
    IO.puts("Error fetching from Github: #{error["message"]}")
    System.halt(2)
  end

  def last(list, count) do
    list
    |> Enum.take(count)
    |> Enum.reverse()
  end

  def sort_into_descending_order(list_of_issues) do
    list_of_issues
    |> Enum.sort(fn i1, i2 ->
      i1["created_at"] >= i2["created_at"]
    end)
  end

  def relevant_keys(issues) do
    Enum.map(
      issues,
      &%{
        number: &1["number"],
        created_at: &1["created_at"],
        title: &1["title"]
      }
    )
  end

  # sample display:
  #  #  | created_at           | title
  # ---------------------------------------------------------------------
  # 889 | 2013-03-17T22:03:13z | MIX_Path environment variable (of sorts)

  def display(issues) do
    widths = get_width(issues)
    # get widest of each field
    # get key names
    # format key line
    # create full-width dashes
    # format each line
  end

  def get_width(issues) do
    Enum.map(issues, fn {key, value} -> {key, _widest(value_len, 0)} end)
  end

  def format_line({number, created_at, title}) do
  end
end
