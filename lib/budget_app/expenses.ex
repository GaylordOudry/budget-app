defmodule BudgetApp.Expenses do
  @moduledoc """
  The expenses context.
  """

  import Ecto.Query, warn: false

  alias BudgetApp.Repo
  alias BudgetApp.Expenses.Expense
  alias BudgetApp.Expenses.ExpenseCategory

  def list_expenses(created_by) when is_binary(created_by) do
    Expense
    |> where([expense], expense.created_by == ^created_by)
    |> order_by([expense], [desc: expense.date, desc: expense.id])
    |> preload(:category)
    |> Repo.all()
  end

  def get_expense!(id, created_by) when is_binary(created_by) do
    Expense
    |> where([expense], expense.id == ^id and expense.created_by == ^created_by)
    |> Repo.one!()
    |> Repo.preload(:category)
  end

  def create_expense(attrs, created_by) when is_binary(created_by) do
    %Expense{}
    |> Expense.changeset(with_created_by(attrs, created_by))
    |> validate_expense_category(created_by)
    |> Repo.insert()
    |> preload_expense_category()
  end

  def update_expense(%Expense{} = expense, attrs, created_by) when is_binary(created_by) do
    expense
    |> Expense.changeset(with_created_by(attrs, created_by))
    |> validate_expense_category(created_by)
    |> Repo.update()
    |> preload_expense_category()
  end

  def delete_expense(%Expense{} = expense) do
    Repo.delete(expense)
  end

  def change_expense(%Expense{} = expense, attrs \\ %{}) do
    Expense.changeset(expense, attrs)
  end

  def list_expense_categories(created_by) when is_binary(created_by) do
    ExpenseCategory
    |> where([category], category.created_by == ^created_by)
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def create_expense_category(attrs, created_by) when is_binary(created_by) do
    %ExpenseCategory{}
    |> ExpenseCategory.changeset(with_created_by(attrs, created_by))
    |> Repo.insert()
  end

  def get_expense_category!(id, created_by) when is_binary(created_by) do
    Repo.one!(
      from category in ExpenseCategory,
        where: category.id == ^id and category.created_by == ^created_by
    )
  end

  def update_expense_category(%ExpenseCategory{} = expense_category, attrs) do
    expense_category
    |> ExpenseCategory.changeset(with_created_by(attrs, expense_category.created_by))
    |> Repo.update()
  end

  def delete_expense_category(%ExpenseCategory{} = expense_category) do
    expense_category
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.no_assoc_constraint(:expenses)
    |> Repo.delete()
  end

  def change_expense_category(%ExpenseCategory{} = expense_category, attrs \\ %{}) do
    ExpenseCategory.changeset(expense_category, attrs)
  end

  defp preload_expense_category({:ok, %Expense{} = expense}) do
    {:ok, Repo.preload(expense, :category)}
  end

  defp preload_expense_category({:error, _} = error), do: error

  defp with_created_by(attrs, created_by) do
    attrs
    |> Map.delete(:created_by)
    |> Map.delete("created_by")
    |> Map.put("created_by", created_by)
  end

  defp validate_expense_category(changeset, created_by) do
    case Ecto.Changeset.get_field(changeset, :category_id) do
      nil ->
        changeset

      category_id ->
        if Repo.exists?(
             from category in ExpenseCategory,
               where: category.id == ^category_id and category.created_by == ^created_by
           ) do
          changeset
        else
          Ecto.Changeset.add_error(changeset, :category_id, "is invalid")
        end
    end
  end
end
