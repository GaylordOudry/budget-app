defmodule BudgetApp.Expenses.ExpenseCategory do
  use Ecto.Schema
  import Ecto.Changeset

  alias BudgetApp.Expenses.Expense

  schema "expense_categories" do
    field :name, :string
    field :created_by, :string
    has_many :expenses, Expense, foreign_key: :category_id

    timestamps(type: :utc_datetime)
  end

  def changeset(expense_category, attrs) do
    expense_category
    |> cast(attrs, [:name, :created_by])
    |> validate_required([:name, :created_by])
    |> validate_length(:created_by, min: 1)
    |> unique_constraint(:name, name: :expense_categories_created_by_name_index)
  end
end
