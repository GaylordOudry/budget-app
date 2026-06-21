defmodule BudgetApp.Incomes do
  @moduledoc """
  The incomes context.
  """

  import Ecto.Query, warn: false

  alias BudgetApp.Incomes.Income
  alias BudgetApp.Repo

  def list_incomes(created_by) when is_binary(created_by) do
    Income
    |> where([income], income.created_by == ^created_by)
    |> order_by([income], [desc: income.date, desc: income.id])
    |> Repo.all()
  end

  def get_income!(id, created_by) when is_binary(created_by) do
    Repo.one!(
      from income in Income,
        where: income.id == ^id and income.created_by == ^created_by
    )
  end

  def create_income(attrs, created_by) when is_binary(created_by) do
    %Income{}
    |> Income.changeset(with_created_by(attrs, created_by))
    |> Repo.insert()
  end

  def update_income(%Income{} = income, attrs, created_by) when is_binary(created_by) do
    income
    |> Income.changeset(with_created_by(attrs, created_by))
    |> Repo.update()
  end

  def delete_income(%Income{} = income) do
    Repo.delete(income)
  end

  def change_income(%Income{} = income, attrs \\ %{}) do
    Income.changeset(income, attrs)
  end

  defp with_created_by(attrs, created_by) do
    attrs
    |> Map.delete(:created_by)
    |> Map.delete("created_by")
    |> Map.put("created_by", created_by)
  end
end
