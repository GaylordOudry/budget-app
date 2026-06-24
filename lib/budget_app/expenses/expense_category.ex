defmodule BudgetApp.Expenses.ExpenseCategory do
  use Ecto.Schema
  import Ecto.Changeset

  alias BudgetApp.Accounts.User
  alias BudgetApp.Expenses.Expense

  schema "expense_categories" do
    field :name, :string
    belongs_to :user, User
    has_many :expenses, Expense, foreign_key: :category_id

    timestamps(type: :utc_datetime)
  end

  def changeset(expense_category, attrs, user \\ nil) do
    expense_category
    |> cast(attrs, [:name])
    |> maybe_put_user(user)
    |> validate_required([:name, :user_id])
    |> foreign_key_constraint(:user_id)
    |> assoc_constraint(:user)
    |> unique_constraint(:name, name: :expense_categories_user_id_name_index)
  end

  defp maybe_put_user(changeset, %User{id: user_id}), do: put_change(changeset, :user_id, user_id)
  defp maybe_put_user(changeset, nil), do: changeset
end
