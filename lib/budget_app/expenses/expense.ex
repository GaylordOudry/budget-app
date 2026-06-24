defmodule BudgetApp.Expenses.Expense do
  use Ecto.Schema
  import Ecto.Changeset

  alias BudgetApp.Accounts.User
  alias BudgetApp.Expenses.ExpenseCategory

  schema "expenses" do
    field :date, :date
    field :amount, :decimal
    field :currency, :string
    field :created_by, :string
    belongs_to :category, ExpenseCategory
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  def changeset(expense, attrs, user \\ nil) do
    expense
    |> cast(attrs, [:date, :amount, :currency, :category_id])
    |> maybe_put_creator(user)
    |> maybe_put_user(user)
    |> validate_required([:date, :amount, :currency, :created_by, :category_id, :user_id])
    |> update_change(:currency, &normalize_currency/1)
    |> validate_length(:currency, is: 3)
    |> validate_format(:currency, ~r/^[A-Z]{3}$/)
    |> validate_length(:created_by, min: 1)
    |> validate_number(:amount, greater_than: 0)
    |> foreign_key_constraint(:category_id)
    |> foreign_key_constraint(:user_id)
    |> assoc_constraint(:category)
    |> assoc_constraint(:user)
  end

  defp maybe_put_creator(changeset, %User{email: email}) do
    case get_field(changeset, :created_by) do
      nil -> put_change(changeset, :created_by, email)
      _created_by -> changeset
    end
  end

  defp maybe_put_creator(changeset, nil), do: changeset

  defp maybe_put_user(changeset, %User{id: user_id}), do: put_change(changeset, :user_id, user_id)
  defp maybe_put_user(changeset, nil), do: changeset

  defp normalize_currency(nil), do: nil

  defp normalize_currency(currency) do
    currency
    |> String.trim()
    |> String.upcase()
  end
end
