{:ok, _} = Application.ensure_all_started(:ex_machina)

Bureaucrat.start
ExUnit.start(formatters: [ExUnit.CLIFormatter, Bureaucrat.Formatter])

Ecto.Adapters.SQL.Sandbox.mode(RedditClone.Repo, :manual)
