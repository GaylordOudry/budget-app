defmodule BudgetApp.Migrations.CreateBudgetTrackingTablesTest do
  use BudgetApp.DataCase, async: false

  alias Ecto.Adapters.SQL

  test "expense categories support naming budget categories per user" do
    columns = column_details("expense_categories")

    assert columns["name"]["data_type"] == "character varying"
    assert columns["name"]["is_nullable"] == "NO"

    assert columns["user_id"]["data_type"] == "bigint"

    assert %{
             "column_name" => "user_id",
             "foreign_table_name" => "users",
             "foreign_column_name" => "id"
           } in foreign_keys("expense_categories")

    assert Enum.any?(index_definitions("expense_categories"), fn index_definition ->
             String.contains?(index_definition, "UNIQUE INDEX") and
               String.contains?(index_definition, "(user_id, name)")
           end)
  end

  test "expenses include the required budget tracking fields" do
    columns = column_details("expenses")

    assert columns["date"]["data_type"] == "date"
    assert columns["date"]["is_nullable"] == "NO"

    assert columns["amount"]["data_type"] == "numeric"
    assert columns["amount"]["is_nullable"] == "NO"

    assert columns["currency"]["character_maximum_length"] == 3
    assert columns["currency"]["is_nullable"] == "NO"

    assert columns["created_by"]["data_type"] == "character varying"
    assert columns["created_by"]["is_nullable"] == "NO"

    assert columns["user_id"]["data_type"] == "bigint"
    assert columns["category_id"]["data_type"] == "bigint"
    assert columns["category_id"]["is_nullable"] == "NO"

    assert %{
             "column_name" => "category_id",
             "foreign_table_name" => "expense_categories",
             "foreign_column_name" => "id"
           } in foreign_keys("expenses")

    assert %{
             "column_name" => "user_id",
             "foreign_table_name" => "users",
             "foreign_column_name" => "id"
           } in foreign_keys("expenses")

    assert has_index?("expenses", "(category_id)")
    assert has_index?("expenses", "(user_id, date)")
  end

  test "incomes include the required budget tracking fields" do
    columns = column_details("incomes")

    assert columns["date"]["data_type"] == "date"
    assert columns["date"]["is_nullable"] == "NO"

    assert columns["amount"]["data_type"] == "numeric"
    assert columns["amount"]["is_nullable"] == "NO"

    assert columns["currency"]["character_maximum_length"] == 3
    assert columns["currency"]["is_nullable"] == "NO"

    assert columns["created_by"]["data_type"] == "character varying"
    assert columns["created_by"]["is_nullable"] == "NO"

    assert columns["user_id"]["data_type"] == "bigint"

    assert %{
             "column_name" => "user_id",
             "foreign_table_name" => "users",
             "foreign_column_name" => "id"
           } in foreign_keys("incomes")

    assert has_index?("incomes", "(user_id, date)")
  end

  test "expense categories cannot be deleted while expenses still reference them" do
    category_id =
      SQL.query!(
        Repo,
        """
        INSERT INTO expense_categories (name, inserted_at, updated_at)
        VALUES ($1, NOW(), NOW())
        RETURNING id
        """,
        ["Housing"]
      ).rows
      |> List.first()
      |> List.first()

    SQL.query!(
      Repo,
      """
      INSERT INTO expenses (date, amount, currency, created_by, category_id, inserted_at, updated_at)
      VALUES ($1, $2, $3, $4, $5, NOW(), NOW())
      """,
      [~D[2026-06-21], Decimal.new("125.50"), "EUR", "owner", category_id]
    )

    assert_raise Postgrex.Error, fn ->
      SQL.query!(Repo, "DELETE FROM expense_categories WHERE id = $1", [category_id])
    end
  end

  defp column_details(table_name) do
    result =
      SQL.query!(
        Repo,
        """
        SELECT column_name, data_type, is_nullable, character_maximum_length
        FROM information_schema.columns
        WHERE table_schema = 'public' AND table_name = $1
        ORDER BY ordinal_position
        """,
        [table_name]
      )

    result.rows
    |> Enum.map(fn row -> row_to_map(result.columns, row) end)
    |> Map.new(fn row -> {row["column_name"], row} end)
  end

  defp foreign_keys(table_name) do
    result =
      SQL.query!(
        Repo,
        """
        SELECT
          kcu.column_name,
          ccu.table_name AS foreign_table_name,
          ccu.column_name AS foreign_column_name
        FROM information_schema.table_constraints AS tc
        JOIN information_schema.key_column_usage AS kcu
          ON tc.constraint_name = kcu.constraint_name
         AND tc.table_schema = kcu.table_schema
        JOIN information_schema.constraint_column_usage AS ccu
          ON ccu.constraint_name = tc.constraint_name
         AND ccu.table_schema = tc.table_schema
        WHERE tc.constraint_type = 'FOREIGN KEY'
          AND tc.table_schema = 'public'
          AND tc.table_name = $1
        ORDER BY kcu.ordinal_position
        """,
        [table_name]
      )

    Enum.map(result.rows, &row_to_map(result.columns, &1))
  end

  defp index_definitions(table_name) do
    result =
      SQL.query!(
        Repo,
        """
        SELECT indexdef
        FROM pg_indexes
        WHERE schemaname = 'public' AND tablename = $1
        ORDER BY indexname
        """,
        [table_name]
      )

    Enum.map(result.rows, fn [index_definition] -> index_definition end)
  end

  defp has_index?(table_name, column_fragment) do
    Enum.any?(index_definitions(table_name), &String.contains?(&1, column_fragment))
  end

  defp row_to_map(columns, row) do
    columns
    |> Enum.zip(row)
    |> Map.new()
  end
end
