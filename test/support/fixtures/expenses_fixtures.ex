defmodule BudgetApp.ExpensesFixtures do
  @moduledoc false

  alias BudgetApp.Expenses

  def expense_category_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "Category #{System.unique_integer([:positive])}"
      })

    {:ok, expense_category} = Expenses.create_expense_category(attrs)
    expense_category
  end

  def expense_fixture(attrs \\ %{}) do
    {category, attrs} =
      case Map.pop(attrs, :category) do
        {nil, attrs} -> {expense_category_fixture(), attrs}
        {category, attrs} -> {category, attrs}
      end

    attrs =
      Enum.into(attrs, %{
        date: ~D[2026-06-21],
        amount: Decimal.new("125.50"),
        currency: "EUR",
        created_by: "owner",
        category_id: category.id
      })

    {:ok, expense} = Expenses.create_expense(attrs)
    expense
  end
end
