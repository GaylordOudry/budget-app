defmodule BudgetAppWeb.ExpenseController do
  use BudgetAppWeb, :controller

  alias BudgetApp.Expenses
  alias BudgetApp.Expenses.Expense

  def index(conn, _params) do
    expenses = Expenses.list_expenses(current_scope(conn))
    render(conn, :index, expenses: expenses)
  end

  def new(conn, _params) do
    scope = current_scope(conn)
    changeset = Expenses.change_expense(scope, %Expense{})

    render(conn, :new,
      form: Phoenix.Component.to_form(changeset),
      category_options: category_options(scope)
    )
  end

  def create(conn, %{"expense" => expense_params}) do
    scope = current_scope(conn)

    case Expenses.create_expense(scope, expense_params) do
      {:ok, expense} ->
        conn
        |> put_flash(:info, "Expense created successfully.")
        |> redirect(to: ~p"/expenses/#{expense}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new,
          form: Phoenix.Component.to_form(changeset),
          category_options: category_options(scope)
        )
    end
  end

  def show(conn, %{"id" => id}) do
    expense = Expenses.get_expense!(current_scope(conn), id)
    render(conn, :show, expense: expense)
  end

  def edit(conn, %{"id" => id}) do
    scope = current_scope(conn)
    expense = Expenses.get_expense!(scope, id)
    changeset = Expenses.change_expense(scope, expense)

    render(conn, :edit,
      expense: expense,
      form: Phoenix.Component.to_form(changeset),
      category_options: category_options(scope)
    )
  end

  def update(conn, %{"id" => id, "expense" => expense_params}) do
    scope = current_scope(conn)
    expense = Expenses.get_expense!(scope, id)

    case Expenses.update_expense(scope, expense, expense_params) do
      {:ok, expense} ->
        conn
        |> put_flash(:info, "Expense updated successfully.")
        |> redirect(to: ~p"/expenses/#{expense}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit,
          expense: expense,
          form: Phoenix.Component.to_form(changeset),
          category_options: category_options(scope)
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    scope = current_scope(conn)
    expense = Expenses.get_expense!(scope, id)
    {:ok, _expense} = Expenses.delete_expense(scope, expense)

    conn
    |> put_flash(:info, "Expense deleted successfully.")
    |> redirect(to: ~p"/expenses")
  end

  defp current_scope(conn), do: conn.assigns.current_scope

  defp category_options(scope) do
    scope
    |> Expenses.list_expense_categories()
    |> Enum.map(&{&1.name, &1.id})
  end
end
