defmodule BudgetApp.Repo.Migrations.AddUserOwnershipToBudgetTrackingTables do
  use Ecto.Migration

  def change do
    alter table(:expense_categories) do
      add :user_id, references(:users, on_delete: :delete_all)
    end

    drop_if_exists unique_index(:expense_categories, [:name])
    create index(:expense_categories, [:user_id])
    create unique_index(:expense_categories, [:user_id, :name])

    alter table(:expenses) do
      add :user_id, references(:users, on_delete: :delete_all)
    end

    drop_if_exists index(:expenses, [:created_by, :date])
    create index(:expenses, [:user_id])
    create index(:expenses, [:user_id, :date])

    alter table(:incomes) do
      add :user_id, references(:users, on_delete: :delete_all)
    end

    drop_if_exists index(:incomes, [:created_by, :date])
    create index(:incomes, [:user_id])
    create index(:incomes, [:user_id, :date])

    execute("""
    UPDATE expenses AS expenses
    SET user_id = users.id
    FROM users
    WHERE expenses.user_id IS NULL
      AND lower(expenses.created_by) = lower(users.email)
    """)

    execute("""
    UPDATE incomes AS incomes
    SET user_id = users.id
    FROM users
    WHERE incomes.user_id IS NULL
      AND lower(incomes.created_by) = lower(users.email)
    """)
  end
end
