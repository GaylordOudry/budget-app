defmodule BudgetApp.Incomes.Income do
  use Ecto.Schema
  import Ecto.Changeset

  schema "incomes" do
    field :date, :date
    field :amount, :decimal
    field :currency, :string
    field :created_by, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(income, attrs) do
    income
    |> cast(attrs, [:date, :amount, :currency, :created_by])
    |> validate_required([:date, :amount, :currency, :created_by])
    |> update_change(:currency, &normalize_currency/1)
    |> validate_length(:currency, is: 3)
    |> validate_format(:currency, ~r/^[A-Z]{3}$/)
    |> validate_length(:created_by, min: 1)
    |> validate_number(:amount, greater_than: 0)
  end

  defp normalize_currency(nil), do: nil

  defp normalize_currency(currency) do
    currency
    |> String.trim()
    |> String.upcase()
  end
end
