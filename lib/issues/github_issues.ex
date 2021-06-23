defmodule Issues.GithubIssues do
  @moduledoc "http handling"
  @user_agent [{"User-agent", "Elixir rev.a.r.cline@gmail.com"}]

  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  def issues_url(user, project) do
    "https://api.github.com/repos/#{user}/#{project}/issues"
  end

  def handle_response({_, %{status_code: status_code, body: body}}) do
    {status_code |> check_for_error(), body |> Poison.Parser.parse!()}
  end

  def check_for_error(200), do: :ok
  def check_for_error(_), do: :error
end
