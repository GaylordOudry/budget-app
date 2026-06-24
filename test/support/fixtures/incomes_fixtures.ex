defmodule BudgetApp.IncomesFixtures do
  @moduledoc false

  import BudgetApp.AccountsFixtures

  alias BudgetApp.Incomes

  def income_fixture(attrs \\ %{}) do
    {scope, attrs} = scope_from_attrs(attrs)

    attrs =
      Enum.into(attrs, %{
        date: ~D[2026-06-21],
        amount: Decimal.new("125.50"),
        currency: "EUR"
      })

    {:ok, income} = Incomes.create_income(scope, attrs)
    income
  end

  defp scope_from_attrs(attrs) do
    case Map.pop(attrs, :scope) do
      {nil, attrs} ->
        case Map.pop(attrs, :user) do
          {nil, attrs} -> {user_scope_fixture(), attrs}
          {user, attrs} -> {user_scope_fixture(user), attrs}
        end

      {scope, attrs} ->
        {scope, attrs}
    end
  end
end
