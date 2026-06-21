defmodule BudgetApp.Users do
  @moduledoc """
  The users context.
  """

  import Ecto.Query, warn: false

  alias BudgetApp.Expenses.Expense
  alias BudgetApp.Expenses.ExpenseCategory
  alias BudgetApp.Incomes.Income
  alias BudgetApp.Repo
  alias BudgetApp.Users.User

  def list_users do
    User
    |> order_by([user], [asc: user.name, asc: user.id])
    |> Repo.all()
  end

  def get_user(id), do: Repo.get(User, id)

  def get_user!(id), do: Repo.get!(User, id)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def delete_user(%User{} = user) do
    if user_has_records?(user) do
      {:error, :user_has_records}
    else
      Repo.delete(user)
    end
  end

  def user_has_records?(%User{name: name}) do
    Repo.exists?(from expense in Expense, where: expense.created_by == ^name) or
      Repo.exists?(from income in Income, where: income.created_by == ^name) or
      Repo.exists?(from category in ExpenseCategory, where: category.created_by == ^name)
  end
end
