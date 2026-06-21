defmodule BudgetApp.Expenses.ExpenseCategory do
  use Ecto.Schema
  import Ecto.Changeset

  alias BudgetApp.Expenses.Expense

  schema "expense_categories" do
    field :name, :string
    has_many :expenses, Expense, foreign_key: :category_id

    timestamps(type: :utc_datetime)
  end

  def changeset(expense_category, attrs) do
    expense_category
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
