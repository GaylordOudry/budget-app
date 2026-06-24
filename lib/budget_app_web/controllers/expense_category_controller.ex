defmodule BudgetAppWeb.ExpenseCategoryController do
  use BudgetAppWeb, :controller

  alias BudgetApp.Expenses
  alias BudgetApp.Expenses.ExpenseCategory

  def index(conn, _params) do
    categories = Expenses.list_expense_categories(current_scope(conn))
    render(conn, :index, categories: categories)
  end

  def new(conn, _params) do
    changeset = Expenses.change_expense_category(current_scope(conn), %ExpenseCategory{})
    render(conn, :new, form: Phoenix.Component.to_form(changeset))
  end

  def create(conn, %{"expense_category" => expense_category_params}) do
    scope = current_scope(conn)

    case Expenses.create_expense_category(scope, expense_category_params) do
      {:ok, expense_category} ->
        conn
        |> put_flash(:info, "Catégorie créée avec succès.")
        |> redirect(to: ~p"/categories/#{expense_category}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, form: Phoenix.Component.to_form(changeset))
    end
  end

  def show(conn, %{"id" => id}) do
    category = Expenses.get_expense_category!(current_scope(conn), id)
    render(conn, :show, category: category)
  end

  def edit(conn, %{"id" => id}) do
    scope = current_scope(conn)
    category = Expenses.get_expense_category!(scope, id)
    changeset = Expenses.change_expense_category(scope, category)

    render(conn, :edit,
      category: category,
      form: Phoenix.Component.to_form(changeset)
    )
  end

  def update(conn, %{"id" => id, "expense_category" => expense_category_params}) do
    scope = current_scope(conn)
    category = Expenses.get_expense_category!(scope, id)

    case Expenses.update_expense_category(scope, category, expense_category_params) do
      {:ok, category} ->
        conn
        |> put_flash(:info, "Catégorie mise à jour avec succès.")
        |> redirect(to: ~p"/categories/#{category}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit,
          category: category,
          form: Phoenix.Component.to_form(changeset)
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    scope = current_scope(conn)
    category = Expenses.get_expense_category!(scope, id)

    case Expenses.delete_expense_category(scope, category) do
      {:ok, _category} ->
        conn
        |> put_flash(:info, "Catégorie supprimée avec succès.")
        |> redirect(to: ~p"/categories")

      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:error, "La catégorie n'a pas pu être supprimée car des dépenses y font encore référence.")
        |> redirect(to: ~p"/categories/#{category}")
    end
  end

  defp current_scope(conn), do: conn.assigns.current_scope
end
