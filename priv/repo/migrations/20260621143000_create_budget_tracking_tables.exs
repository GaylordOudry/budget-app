defmodule BudgetApp.Repo.Migrations.CreateBudgetTrackingTables do
  use Ecto.Migration

  def change do
    create table(:expense_categories) do
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:expense_categories, [:name])

    create table(:expenses) do
      add :date, :date, null: false
      add :amount, :decimal, null: false
      add :currency, :string, size: 3, null: false
      add :created_by, :string, null: false
      add :category_id, references(:expense_categories, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:expenses, [:category_id])
    create index(:expenses, [:created_by, :date])
    create constraint(:expenses, :expenses_amount_must_be_positive, check: "amount > 0")
    create constraint(:expenses, :expenses_currency_must_have_three_characters,
             check: "char_length(currency) = 3"
           )

    create table(:incomes) do
      add :date, :date, null: false
      add :amount, :decimal, null: false
      add :currency, :string, size: 3, null: false
      add :created_by, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:incomes, [:created_by, :date])
    create constraint(:incomes, :incomes_amount_must_be_positive, check: "amount > 0")
    create constraint(:incomes, :incomes_currency_must_have_three_characters,
             check: "char_length(currency) = 3"
           )
  end
end
