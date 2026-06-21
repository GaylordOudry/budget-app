defmodule BudgetApp.ExpensesFixtures do
  @moduledoc false

  alias BudgetApp.Expenses

  def expense_category_fixture(attrs \\ %{}) do
    created_by = Map.get(attrs, :created_by) || Map.get(attrs, "created_by") || "owner"

    attrs =
      Enum.into(attrs, %{
        name: "Category #{System.unique_integer([:positive])}"
      })

    attrs =
      attrs
      |> Map.delete(:created_by)
      |> Map.delete("created_by")

    {:ok, expense_category} = Expenses.create_expense_category(attrs, created_by)
    expense_category
  end

  def expense_fixture(attrs \\ %{}) do
    created_by = Map.get(attrs, :created_by) || Map.get(attrs, "created_by") || "owner"

    {category, attrs} =
      case Map.pop(attrs, :category) do
        {nil, attrs} -> {expense_category_fixture(%{created_by: created_by}), attrs}
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

    attrs =
      attrs
      |> Map.delete(:created_by)
      |> Map.delete("created_by")

    {:ok, expense} = Expenses.create_expense(attrs, created_by)
    expense
  end
end
