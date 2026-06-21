defmodule BudgetApp.IncomesFixtures do
  @moduledoc false

  alias BudgetApp.Incomes

  def income_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        date: ~D[2026-06-21],
        amount: Decimal.new("125.50"),
        currency: "EUR",
        created_by: "owner"
      })

    {:ok, income} = Incomes.create_income(attrs)
    income
  end
end
