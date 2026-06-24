defmodule BudgetApp.Expenses do
  @moduledoc """
  The expenses context.
  """

  import Ecto.Query, warn: false

  alias BudgetApp.Accounts.Scope
  alias BudgetApp.Accounts.User
  alias BudgetApp.Expenses.Expense
  alias BudgetApp.Expenses.ExpenseCategory
  alias BudgetApp.Repo

  def list_expenses(scope) do
    Expense
    |> visible_to_scope(scope)
    |> order_by([expense], [desc: expense.date, desc: expense.id])
    |> preload(:category)
    |> Repo.all()
  end

  def get_expense!(scope, id) do
    Expense
    |> visible_to_scope(scope)
    |> where([expense], expense.id == ^id)
    |> preload(:category)
    |> Repo.one!()
  end

  def get_owned_expense!(scope, id) do
    Expense
    |> owned_by_scope(scope)
    |> where([expense], expense.id == ^id)
    |> preload(:category)
    |> Repo.one!()
  end

  def create_expense(scope, attrs \\ %{}) do
    %Expense{}
    |> Expense.changeset(attrs, scope_user(scope))
    |> validate_scoped_category(scope)
    |> Repo.insert()
    |> preload_expense_category()
  end

  def update_expense(scope, %Expense{} = expense, attrs) do
    expense
    |> ensure_owned_by!(scope)
    |> Expense.changeset(attrs, scope_user(scope))
    |> validate_scoped_category(scope)
    |> Repo.update()
    |> preload_expense_category()
  end

  def delete_expense(scope, %Expense{} = expense) do
    expense
    |> ensure_owned_by!(scope)
    |> Repo.delete()
  end

  def change_expense(scope, %Expense{} = expense, attrs \\ %{}) do
    expense
    |> maybe_ensure_owned_by(scope)
    |> Expense.changeset(attrs, scope_user(scope))
    |> validate_scoped_category(scope)
  end

  def list_expense_categories(scope) do
    ExpenseCategory
    |> visible_to_scope(scope)
    |> order_by(asc: :name)
    |> Repo.all()
  end

  def create_expense_category(scope, attrs \\ %{}) do
    %ExpenseCategory{}
    |> ExpenseCategory.changeset(attrs, scope_user(scope))
    |> Repo.insert()
  end

  def get_expense_category!(scope, id) do
    ExpenseCategory
    |> visible_to_scope(scope)
    |> where([expense_category], expense_category.id == ^id)
    |> Repo.one!()
  end

  def get_owned_expense_category!(scope, id) do
    ExpenseCategory
    |> owned_by_scope(scope)
    |> where([expense_category], expense_category.id == ^id)
    |> Repo.one!()
  end

  def update_expense_category(scope, %ExpenseCategory{} = expense_category, attrs) do
    expense_category
    |> ensure_owned_by!(scope)
    |> ExpenseCategory.changeset(attrs, scope_user(scope))
    |> Repo.update()
  end

  def delete_expense_category(scope, %ExpenseCategory{} = expense_category) do
    expense_category
    |> ensure_owned_by!(scope)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.no_assoc_constraint(:expenses)
    |> Repo.delete()
  end

  def change_expense_category(scope, %ExpenseCategory{} = expense_category, attrs \\ %{}) do
    expense_category
    |> maybe_ensure_owned_by(scope)
    |> ExpenseCategory.changeset(attrs, scope_user(scope))
  end

  defp validate_scoped_category(changeset, scope) do
    case Ecto.Changeset.get_field(changeset, :category_id) do
      nil ->
        changeset

      category_id ->
        category_exists? =
          ExpenseCategory
          |> visible_to_scope(scope)
          |> where([expense_category], expense_category.id == ^category_id)
          |> Repo.exists?()

        if category_exists? do
          changeset
        else
          Ecto.Changeset.add_error(changeset, :category_id, "is invalid")
        end
    end
  end

  defp preload_expense_category({:ok, %Expense{} = expense}) do
    {:ok, Repo.preload(expense, :category)}
  end

  defp preload_expense_category({:error, _} = error), do: error

  defp maybe_ensure_owned_by(%schema{id: nil} = struct, _scope) when is_atom(schema), do: struct
  defp maybe_ensure_owned_by(struct, scope), do: ensure_owned_by!(struct, scope)

  defp visible_to_scope(query, scope) do
    where(query, [schema], schema.user_id == ^scope_user_id(scope) or schema.shared)
  end

  defp owned_by_scope(query, scope) do
    where(query, [schema], schema.user_id == ^scope_user_id(scope))
  end

  defp ensure_owned_by!(%schema{user_id: user_id} = struct, scope) when is_atom(schema) do
    if user_id == scope_user_id(scope) do
      struct
    else
      raise Ecto.NoResultsError, queryable: schema
    end
  end

  defp scope_user(%Scope{user: %User{} = user}), do: user

  defp scope_user_id(%Scope{user: %User{id: user_id}}), do: user_id
end
