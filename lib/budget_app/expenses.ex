defmodule BudgetApp.Expenses do
  @moduledoc """
  The expenses context.
  """

  import Ecto.Query, warn: false

  alias BudgetApp.Repo
  alias BudgetApp.Expenses.Expense
  alias BudgetApp.Expenses.ExpenseCategory

  def list_expenses do
    Expense
    |> order_by([expense], [desc: expense.date, desc: expense.id])
    |> preload(:category)
    |> Repo.all()
  end

  def get_expense!(id) do
    Expense
    |> Repo.get!(id)
    |> Repo.preload(:category)
  end

  def create_expense(attrs \\ %{}) do
    %Expense{}
    |> Expense.changeset(attrs)
    |> Repo.insert()
    |> preload_expense_category()
  end

  def update_expense(%Expense{} = expense, attrs) do
    expense
    |> Expense.changeset(attrs)
    |> Repo.update()
    |> preload_expense_category()
  end

  def delete_expense(%Expense{} = expense) do
    Repo.delete(expense)
  end

  def change_expense(%Expense{} = expense, attrs \\ %{}) do
    Expense.changeset(expense, attrs)
  end

  def list_expense_categories do
    ExpenseCategory
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def create_expense_category(attrs \\ %{}) do
    %ExpenseCategory{}
    |> ExpenseCategory.changeset(attrs)
    |> Repo.insert()
  end

  defp preload_expense_category({:ok, %Expense{} = expense}) do
    {:ok, Repo.preload(expense, :category)}
  end

  defp preload_expense_category({:error, _} = error), do: error
end
