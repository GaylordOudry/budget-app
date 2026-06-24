defmodule BudgetApp.ExpensesFixtures do
  @moduledoc false

  import BudgetApp.AccountsFixtures

  alias BudgetApp.Expenses

  def expense_category_fixture(attrs \\ %{}) do
    {scope, attrs} = scope_from_attrs(attrs)

    attrs =
      Enum.into(attrs, %{
        name: "Category #{System.unique_integer([:positive])}"
      })

    {:ok, expense_category} = Expenses.create_expense_category(scope, attrs)
    expense_category
  end

  def expense_fixture(attrs \\ %{}) do
    {scope, attrs} = scope_from_attrs(attrs)

    {category, attrs} =
      case Map.pop(attrs, :category) do
        {nil, attrs} -> {expense_category_fixture(%{scope: scope}), attrs}
        {category, attrs} -> {category, attrs}
      end

    attrs =
      Enum.into(attrs, %{
        date: ~D[2026-06-21],
        amount: Decimal.new("125.50"),
        currency: "EUR",
        category_id: category.id
      })

    {:ok, expense} = Expenses.create_expense(scope, attrs)
    expense
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
