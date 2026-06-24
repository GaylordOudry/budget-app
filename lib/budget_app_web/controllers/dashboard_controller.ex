defmodule BudgetAppWeb.DashboardController do
  use BudgetAppWeb, :controller

  alias BudgetApp.Expenses
  alias BudgetApp.Incomes
  alias Decimal, as: D

  def index(conn, _params) do
    scope = current_scope(conn)
    expenses = Expenses.list_expenses(scope)
    incomes = Incomes.list_incomes(scope)

    render(conn, :index,
      expense_totals: totals_by_currency(expenses),
      income_totals: totals_by_currency(incomes),
      monthly_sections: monthly_sections(expenses, incomes)
    )
  end

  defp current_scope(conn), do: conn.assigns.current_scope

  defp totals_by_currency(entries) do
    entries
    |> Enum.group_by(& &1.currency)
    |> Enum.map(fn {currency, records} ->
      %{
        currency: currency,
        total: Enum.reduce(records, D.new(0), fn record, total -> D.add(total, record.amount) end),
        count: length(records)
      }
    end)
    |> Enum.sort_by(& &1.currency)
  end

  defp monthly_sections(expenses, incomes) do
    month_range = month_range(expenses ++ incomes)

    currencies =
      expenses
      |> Enum.map(& &1.currency)
      |> Kernel.++(Enum.map(incomes, & &1.currency))
      |> Enum.uniq()
      |> Enum.sort()

    expense_totals = monthly_totals(expenses)
    income_totals = monthly_totals(incomes)

    Enum.map(currencies, fn currency ->
      months =
        Enum.map(month_range, fn month ->
          expense_total = Map.get(expense_totals, {currency, month}, D.new(0))
          income_total = Map.get(income_totals, {currency, month}, D.new(0))
          net_total = D.sub(income_total, expense_total)

          %{
            label: Calendar.strftime(month, "%m/%Y"),
            expense_total: expense_total,
            income_total: income_total,
            net_total: net_total,
            positive?: D.compare(net_total, D.new(0)) != :lt,
            absolute_net_total: absolute_decimal(net_total)
          }
        end)

      max_absolute_net_total =
        Enum.reduce(months, D.new(0), fn month, current_max ->
          max_decimal(current_max, month.absolute_net_total)
        end)

      %{
        currency: currency,
        months: months,
        max_absolute_net_total: max_non_zero(max_absolute_net_total)
      }
    end)
  end

  defp monthly_totals(entries) do
    Enum.reduce(entries, %{}, fn entry, totals ->
      Map.update(
        totals,
        {entry.currency, month_start(entry.date)},
        entry.amount,
        &D.add(&1, entry.amount)
      )
    end)
  end

  defp month_range([]), do: []

  defp month_range(entries) do
    months =
      entries
      |> Enum.map(&month_start(&1.date))
      |> Enum.sort_by(&{&1.year, &1.month})

    build_month_range(List.first(months), List.last(months), [])
  end

  defp build_month_range(current_month, last_month, acc) do
    next_acc = [current_month | acc]

    if Date.compare(current_month, last_month) == :eq do
      Enum.reverse(next_acc)
    else
      build_month_range(next_month(current_month), last_month, next_acc)
    end
  end

  defp next_month(%Date{year: year, month: 12}), do: Date.new!(year + 1, 1, 1)
  defp next_month(%Date{year: year, month: month}), do: Date.new!(year, month + 1, 1)
  defp month_start(%Date{year: year, month: month}), do: Date.new!(year, month, 1)

  defp absolute_decimal(decimal) do
    if D.compare(decimal, D.new(0)) == :lt do
      D.mult(decimal, -1)
    else
      decimal
    end
  end

  defp max_decimal(left, right) do
    if D.compare(left, right) == :lt, do: right, else: left
  end

  defp max_non_zero(decimal) do
    if D.compare(decimal, D.new(0)) == :eq, do: D.new(1), else: decimal
  end
end
