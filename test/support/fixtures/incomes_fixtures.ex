defmodule BudgetApp.IncomesFixtures do
  @moduledoc false

  alias BudgetApp.Incomes

  def income_fixture(attrs \\ %{}) do
    created_by = Map.get(attrs, :created_by) || Map.get(attrs, "created_by") || "owner"

    attrs =
      Enum.into(attrs, %{
        date: ~D[2026-06-21],
        amount: Decimal.new("125.50"),
        currency: "EUR",
        created_by: "owner"
      })

    attrs =
      attrs
      |> Map.delete(:created_by)
      |> Map.delete("created_by")

    {:ok, income} = Incomes.create_income(attrs, created_by)
    income
  end
end
