defmodule BudgetAppWeb.IncomeController do
  use BudgetAppWeb, :controller

  alias BudgetApp.Incomes
  alias BudgetApp.Incomes.Income

  def index(conn, _params) do
    incomes = Incomes.list_incomes(current_user_name(conn))
    render(conn, :index, incomes: incomes)
  end

  def new(conn, _params) do
    changeset = Incomes.change_income(%Income{created_by: current_user_name(conn)})
    render(conn, :new, form: Phoenix.Component.to_form(changeset))
  end

  def create(conn, %{"income" => income_params}) do
    case Incomes.create_income(income_params, current_user_name(conn)) do
      {:ok, income} ->
        conn
        |> put_flash(:info, "Revenu créé avec succès.")
        |> redirect(to: ~p"/incomes/#{income}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, form: Phoenix.Component.to_form(changeset))
    end
  end

  def show(conn, %{"id" => id}) do
    income = Incomes.get_income!(id, current_user_name(conn))
    render(conn, :show, income: income)
  end

  def edit(conn, %{"id" => id}) do
    income = Incomes.get_income!(id, current_user_name(conn))
    changeset = Incomes.change_income(income)

    render(conn, :edit,
      income: income,
      form: Phoenix.Component.to_form(changeset)
    )
  end

  def update(conn, %{"id" => id, "income" => income_params}) do
    current_user_name = current_user_name(conn)
    income = Incomes.get_income!(id, current_user_name)

    case Incomes.update_income(income, income_params, current_user_name) do
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
    income = Incomes.get_income!(id, current_user_name(conn))
    {:ok, _income} = Incomes.delete_income(income)

    conn
    |> put_flash(:info, "Revenu supprimé avec succès.")
    |> redirect(to: ~p"/incomes")
  end

  defp current_user_name(conn), do: conn.assigns.current_user.name
end
