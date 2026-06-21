defmodule BudgetAppWeb.ExpenseController do
  use BudgetAppWeb, :controller

  alias BudgetApp.Expenses
  alias BudgetApp.Expenses.Expense

  def index(conn, _params) do
    expenses = Expenses.list_expenses(current_user_name(conn))
    render(conn, :index, expenses: expenses)
  end

  def new(conn, _params) do
    changeset = Expenses.change_expense(%Expense{created_by: current_user_name(conn)})

    render(conn, :new,
      form: Phoenix.Component.to_form(changeset),
      category_options: category_options(current_user_name(conn))
    )
  end

  def create(conn, %{"expense" => expense_params}) do
    current_user_name = current_user_name(conn)

    case Expenses.create_expense(expense_params, current_user_name) do
      {:ok, expense} ->
        conn
        |> put_flash(:info, "Expense created successfully.")
        |> redirect(to: ~p"/expenses/#{expense}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new,
          form: Phoenix.Component.to_form(changeset),
          category_options: category_options(current_user_name)
        )
    end
  end

  def show(conn, %{"id" => id}) do
    expense = Expenses.get_expense!(id, current_user_name(conn))
    render(conn, :show, expense: expense)
  end

  def edit(conn, %{"id" => id}) do
    current_user_name = current_user_name(conn)
    expense = Expenses.get_expense!(id, current_user_name)
    changeset = Expenses.change_expense(expense)

    render(conn, :edit,
      expense: expense,
      form: Phoenix.Component.to_form(changeset),
      category_options: category_options(current_user_name)
    )
  end

  def update(conn, %{"id" => id, "expense" => expense_params}) do
    current_user_name = current_user_name(conn)
    expense = Expenses.get_expense!(id, current_user_name)

    case Expenses.update_expense(expense, expense_params, current_user_name) do
      {:ok, expense} ->
        conn
        |> put_flash(:info, "Expense updated successfully.")
        |> redirect(to: ~p"/expenses/#{expense}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit,
          expense: expense,
          form: Phoenix.Component.to_form(changeset),
          category_options: category_options(current_user_name)
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    expense = Expenses.get_expense!(id, current_user_name(conn))
    {:ok, _expense} = Expenses.delete_expense(expense)

    conn
    |> put_flash(:info, "Expense deleted successfully.")
    |> redirect(to: ~p"/expenses")
  end

  defp category_options(current_user_name) do
    Expenses.list_expense_categories(current_user_name)
    |> Enum.map(&{&1.name, &1.id})
  end

  defp current_user_name(conn), do: conn.assigns.current_user.name
end
