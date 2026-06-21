defmodule BudgetAppWeb.ExpenseCategoryController do
  use BudgetAppWeb, :controller

  alias BudgetApp.Expenses
  alias BudgetApp.Expenses.ExpenseCategory

  def index(conn, _params) do
    categories = Expenses.list_expense_categories()
    render(conn, :index, categories: categories)
  end

  def new(conn, _params) do
    changeset = Expenses.change_expense_category(%ExpenseCategory{})
    render(conn, :new, form: Phoenix.Component.to_form(changeset))
  end

  def create(conn, %{"expense_category" => expense_category_params}) do
    case Expenses.create_expense_category(expense_category_params) do
      {:ok, expense_category} ->
        conn
        |> put_flash(:info, "Category created successfully.")
        |> redirect(to: ~p"/categories/#{expense_category}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, form: Phoenix.Component.to_form(changeset))
    end
  end

  def show(conn, %{"id" => id}) do
    category = Expenses.get_expense_category!(id)
    render(conn, :show, category: category)
  end

  def edit(conn, %{"id" => id}) do
    category = Expenses.get_expense_category!(id)
    changeset = Expenses.change_expense_category(category)

    render(conn, :edit,
      category: category,
      form: Phoenix.Component.to_form(changeset)
    )
  end

  def update(conn, %{"id" => id, "expense_category" => expense_category_params}) do
    category = Expenses.get_expense_category!(id)

    case Expenses.update_expense_category(category, expense_category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Category updated successfully.")
        |> redirect(to: ~p"/categories/#{category}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit,
          category: category,
          form: Phoenix.Component.to_form(changeset)
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    category = Expenses.get_expense_category!(id)

    case Expenses.delete_expense_category(category) do
      {:ok, _category} ->
        conn
        |> put_flash(:info, "Category deleted successfully.")
        |> redirect(to: ~p"/categories")

      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:error, "Category could not be deleted because expenses still reference it.")
        |> redirect(to: ~p"/categories/#{category}")
    end
  end
end
