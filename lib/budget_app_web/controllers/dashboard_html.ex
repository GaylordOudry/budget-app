defmodule BudgetAppWeb.DashboardHTML do
  use BudgetAppWeb, :html

  alias Decimal, as: D

  embed_templates "dashboard_html/*"

  def money_amount(amount, currency) do
    "#{D.to_string(amount, :normal)} #{currency}"
  end

  def signed_money_amount(amount, currency) do
    prefix =
      if D.compare(amount, D.new(0)) == :lt do
        ""
      else
        "+"
      end

    prefix <> money_amount(amount, currency)
  end

  def monthly_bar_height(amount, max_amount) do
    if D.compare(amount, D.new(0)) == :eq do
      6
    else
      percentage =
        amount
        |> D.div(max_amount)
        |> D.mult(100)
        |> D.round(0)
        |> D.to_string(:normal)
        |> String.to_integer()

      max(18, percentage)
    end
  end
end
