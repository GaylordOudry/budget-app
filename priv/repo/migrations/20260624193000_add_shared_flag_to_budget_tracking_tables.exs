defmodule BudgetApp.Repo.Migrations.AddSharedFlagToBudgetTrackingTables do
  use Ecto.Migration

  def change do
    alter table(:expense_categories) do
      add :shared, :boolean, null: false, default: false
    end

    create index(:expense_categories, [:shared])

    alter table(:expenses) do
      add :shared, :boolean, null: false, default: false
    end

    create index(:expenses, [:shared])

    alter table(:incomes) do
      add :shared, :boolean, null: false, default: false
    end

    create index(:incomes, [:shared])
  end
end
