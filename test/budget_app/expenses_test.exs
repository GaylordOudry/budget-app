defmodule BudgetApp.ExpensesTest do
  use BudgetApp.DataCase, async: true

  import BudgetApp.ExpensesFixtures

  alias BudgetApp.Expenses

  describe "expense categories" do
    test "list_expense_categories/1 returns categories ordered by name for one user" do
      beta = expense_category_fixture(%{name: "Beta", created_by: "owner"})
      alpha = expense_category_fixture(%{name: "Alpha", created_by: "owner"})
      _other = expense_category_fixture(%{name: "Elsewhere", created_by: "reviewer"})

      assert Expenses.list_expense_categories("owner") == [alpha, beta]
    end

    test "get_expense_category!/2 returns the category for its owner" do
      category = expense_category_fixture(%{created_by: "owner"})

      assert Expenses.get_expense_category!(category.id, "owner") == category
    end

    test "update_expense_category/2 updates the category" do
      category = expense_category_fixture(%{created_by: "owner"})

      assert {:ok, category} = Expenses.update_expense_category(category, %{name: "Updated"})
      assert category.name == "Updated"
    end

    test "change_expense_category/1 returns a changeset" do
      category = expense_category_fixture(%{created_by: "owner"})

      assert %Ecto.Changeset{} = Expenses.change_expense_category(category)
    end

    test "delete_expense_category/1 deletes categories without expenses" do
      category = expense_category_fixture(%{created_by: "owner"})

      assert {:ok, _category} = Expenses.delete_expense_category(category)
      assert_raise Ecto.NoResultsError, fn -> Expenses.get_expense_category!(category.id, "owner") end
    end

    test "delete_expense_category/1 returns an error when expenses still reference the category" do
      category = expense_category_fixture(%{created_by: "owner"})
      _expense = expense_fixture(%{category: category, created_by: "owner"})

      assert {:error, changeset} = Expenses.delete_expense_category(category)
      assert "are still associated with this entry" in errors_on(changeset).expenses
    end

    test "create_expense/2 rejects categories owned by another user" do
      category = expense_category_fixture(%{created_by: "reviewer"})

      assert {:error, changeset} =
               Expenses.create_expense(
                 %{date: "2026-06-21", amount: "125.50", currency: "EUR", category_id: category.id},
                 "owner"
               )

      assert "is invalid" in errors_on(changeset).category_id
    end
  end
end
