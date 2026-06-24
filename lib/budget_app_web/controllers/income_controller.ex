defmodule BudgetAppWeb.IncomeController do
  use BudgetAppWeb, :controller

  alias BudgetApp.Incomes
  alias BudgetApp.Incomes.Income

  def index(conn, _params) do
    incomes = Incomes.list_incomes(current_scope(conn))
    render(conn, :index, incomes: incomes)
  end

  def new(conn, _params) do
    changeset = Incomes.change_income(current_scope(conn), %Income{})
    render(conn, :new, form: Phoenix.Component.to_form(changeset))
  end

  def create(conn, %{"income" => income_params}) do
    scope = current_scope(conn)

    case Incomes.create_income(scope, income_params) do
      {:ok, income} ->
        conn
        |> put_flash(:info, "Revenu créé avec succès.")
        |> redirect(to: ~p"/incomes/#{income}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, form: Phoenix.Component.to_form(changeset))
    end
  end

  def show(conn, %{"id" => id}) do
    income = Incomes.get_income!(current_scope(conn), id)
    render(conn, :show, income: income)
  end

  def edit(conn, %{"id" => id}) do
    scope = current_scope(conn)
    income = Incomes.get_owned_income!(scope, id)
    changeset = Incomes.change_income(scope, income)

    render(conn, :edit,
      income: income,
      form: Phoenix.Component.to_form(changeset)
    )
  end

  def update(conn, %{"id" => id, "income" => income_params}) do
    scope = current_scope(conn)
    income = Incomes.get_owned_income!(scope, id)

    case Incomes.update_income(scope, income, income_params) do
      {:ok, income} ->
        conn
        |> put_flash(:info, "Revenu mis à jour avec succès.")
        |> redirect(to: ~p"/incomes/#{income}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit,
          income: income,
          form: Phoenix.Component.to_form(changeset)
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    scope = current_scope(conn)
    income = Incomes.get_owned_income!(scope, id)
    {:ok, _income} = Incomes.delete_income(scope, income)

    conn
    |> put_flash(:info, "Revenu supprimé avec succès.")
    |> redirect(to: ~p"/incomes")
  end

  defp current_scope(conn), do: conn.assigns.current_scope
end
