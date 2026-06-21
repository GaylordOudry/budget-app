defmodule BudgetApp.Incomes do
  @moduledoc """
  The incomes context.
  """

  import Ecto.Query, warn: false

  alias BudgetApp.Incomes.Income
  alias BudgetApp.Repo

  def list_incomes do
    Income
    |> order_by([income], [desc: income.date, desc: income.id])
    |> Repo.all()
  end

  def get_income!(id), do: Repo.get!(Income, id)

  def create_income(attrs \\ %{}) do
    %Income{}
    |> Income.changeset(attrs)
    |> Repo.insert()
  end

  def update_income(%Income{} = income, attrs) do
    income
    |> Income.changeset(attrs)
    |> Repo.update()
  end

  def delete_income(%Income{} = income) do
    Repo.delete(income)
  end

  def change_income(%Income{} = income, attrs \\ %{}) do
    Income.changeset(income, attrs)
  end
end
