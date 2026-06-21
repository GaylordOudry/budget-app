defmodule BudgetApp.Expenses.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  alias BudgetApp.Expenses.ExpenseCategory

  schema "expenses" do
    field :date, :date
    field :amount, :decimal
    field :currency, :string
    field :created_by, :string
    belongs_to :category, ExpenseCategory

    timestamps(type: :utc_datetime)
  end

  def changeset(expense, attrs) do
    expense
    |> cast(attrs, [:date, :amount, :currency, :created_by, :category_id])
    |> validate_required([:date, :amount, :currency, :created_by, :category_id])
    |> update_change(:currency, &normalize_currency/1)
    |> validate_length(:currency, is: 3)
    |> validate_format(:currency, ~r/^[A-Z]{3}$/)
    |> validate_length(:created_by, min: 1)
    |> validate_number(:amount, greater_than: 0)
    |> foreign_key_constraint(:category_id)
    |> assoc_constraint(:category)
  end

  defp normalize_currency(nil), do: nil

  defp normalize_currency(currency) do
    currency
    |> String.trim()
    |> String.upcase()
  end
end
