defmodule BudgetApp.ExpensesTest do
  use BudgetApp.DataCase, async: true

  import BudgetApp.ExpensesFixtures

  alias BudgetApp.Expenses

  describe "expense categories" do
    test "list_expense_categories/0 returns categories ordered by name" do
      beta = expense_category_fixture(%{name: "Beta"})
      alpha = expense_category_fixture(%{name: "Alpha"})

      assert Expenses.list_expense_categories() == [alpha, beta]
    end

    test "get_expense_category!/1 returns the category" do
      category = expense_category_fixture()

      assert Expenses.get_expense_category!(category.id) == category
    end

    test "update_expense_category/2 updates the category" do
      category = expense_category_fixture()

      assert {:ok, category} = Expenses.update_expense_category(category, %{name: "Updated"})
      assert category.name == "Updated"
    end

    test "change_expense_category/1 returns a changeset" do
      category = expense_category_fixture()

      assert %Ecto.Changeset{} = Expenses.change_expense_category(category)
    end

    test "delete_expense_category/1 deletes categories without expenses" do
      category = expense_category_fixture()

      assert {:ok, _category} = Expenses.delete_expense_category(category)
      assert_raise Ecto.NoResultsError, fn -> Expenses.get_expense_category!(category.id) end
    end

    test "delete_expense_category/1 returns an error when expenses still reference the category" do
      category = expense_category_fixture()
      _expense = expense_fixture(%{category: category})

      assert {:error, changeset} = Expenses.delete_expense_category(category)
      assert "are still associated with this entry" in errors_on(changeset).expenses
    end
  end
end
