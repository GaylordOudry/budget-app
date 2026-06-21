defmodule BudgetApp.Repo do
  use Ecto.Repo,
    otp_app: :budget_app,
    adapter: Ecto.Adapters.Postgres
end
