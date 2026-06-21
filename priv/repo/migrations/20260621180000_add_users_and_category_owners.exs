defmodule BudgetApp.Repo.Migrations.AddUsersAndCategoryOwners do
  use Ecto.Migration

  def up do
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:name])
    create unique_index(:users, [:email])

    create table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :authenticated_at, :utc_datetime

      timestamps(type: :utc_datetime, updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])

    alter table(:expense_categories) do
      add :created_by, :string
    end

    execute("""
    UPDATE expense_categories AS categories
    SET created_by = owners.created_by
    FROM (
      SELECT category_id, MIN(created_by) AS created_by
      FROM expenses
      GROUP BY category_id
    ) AS owners
    WHERE owners.category_id = categories.id
      AND categories.created_by IS NULL
    """)

    execute("""
    INSERT INTO expense_categories (name, created_by, inserted_at, updated_at)
    SELECT DISTINCT categories.name, expenses.created_by, NOW() AT TIME ZONE 'UTC', NOW() AT TIME ZONE 'UTC'
    FROM expenses
    JOIN expense_categories AS categories
      ON categories.id = expenses.category_id
    WHERE categories.created_by IS NOT NULL
      AND categories.created_by <> expenses.created_by
    ON CONFLICT DO NOTHING
    """)

    execute("""
    UPDATE expenses AS expenses
    SET category_id = duplicates.id
    FROM expense_categories AS originals,
         expense_categories AS duplicates
    WHERE expenses.category_id = originals.id
      AND originals.name = duplicates.name
      AND duplicates.created_by = expenses.created_by
      AND originals.created_by IS NOT NULL
      AND originals.created_by <> expenses.created_by
    """)

    execute("""
    UPDATE expense_categories
    SET created_by = 'default'
    WHERE created_by IS NULL
    """)

    flush()

    alter table(:expense_categories) do
      modify :created_by, :string, null: false
    end

    drop unique_index(:expense_categories, [:name])
    create index(:expense_categories, [:created_by])
    create unique_index(:expense_categories, [:created_by, :name])
  end

  def down do
    drop unique_index(:users_tokens, [:context, :token])
    drop index(:users_tokens, [:user_id])
    drop table(:users_tokens)

    drop unique_index(:users, [:email])
    drop unique_index(:expense_categories, [:created_by, :name])
    drop index(:expense_categories, [:created_by])
    create unique_index(:expense_categories, [:name])

    alter table(:expense_categories) do
      remove :created_by
    end

    drop table(:users)
  end
end
