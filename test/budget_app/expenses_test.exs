defmodule BudgetApp.ExpensesTest do
  use BudgetApp.DataCase, async: true

  import BudgetApp.AccountsFixtures
  import BudgetApp.ExpensesFixtures

  alias BudgetApp.Expenses
  alias BudgetApp.Expenses.Expense
  alias BudgetApp.Expenses.ExpenseCategory

  @invalid_expense_attrs %{amount: nil, currency: nil, date: nil, category_id: nil}

  describe "expense categories" do
    setup do
      %{scope: user_scope_fixture(), other_scope: user_scope_fixture()}
    end

    test "list_expense_categories/1 returns only categories ordered by name", %{scope: scope, other_scope: other_scope} do
      beta = expense_category_fixture(%{scope: scope, name: "Beta"})
      alpha = expense_category_fixture(%{scope: scope, name: "Alpha"})
      _other = expense_category_fixture(%{scope: other_scope, name: "Gamma"})

      assert Expenses.list_expense_categories(scope) == [alpha, beta]
    end

    test "get_expense_category!/2 returns only the scoped category", %{scope: scope, other_scope: other_scope} do
      category = expense_category_fixture(%{scope: scope})
      other_category = expense_category_fixture(%{scope: other_scope})

      assert Expenses.get_expense_category!(scope, category.id) == category
      assert_raise Ecto.NoResultsError, fn -> Expenses.get_expense_category!(scope, other_category.id) end
    end

    test "create_expense_category/2 assigns the scoped user", %{scope: scope} do
      assert {:ok, %ExpenseCategory{} = category} = Expenses.create_expense_category(scope, %{name: "Housing"})
      assert category.user_id == scope.user.id
    end

    test "update_expense_category/3 updates the category", %{scope: scope} do
      category = expense_category_fixture(%{scope: scope})

      assert {:ok, category} = Expenses.update_expense_category(scope, category, %{name: "Updated"})
      assert category.name == "Updated"
    end

    test "change_expense_category/3 returns a changeset", %{scope: scope} do
      category = expense_category_fixture(%{scope: scope})

      assert %Ecto.Changeset{} = Expenses.change_expense_category(scope, category)
    end

    test "delete_expense_category/2 deletes categories without expenses", %{scope: scope} do
      category = expense_category_fixture(%{scope: scope})

      assert {:ok, _category} = Expenses.delete_expense_category(scope, category)
      assert_raise Ecto.NoResultsError, fn -> Expenses.get_expense_category!(scope, category.id) end
    end

    test "delete_expense_category/2 returns an error when expenses still reference the category", %{scope: scope} do
      category = expense_category_fixture(%{scope: scope})
      _expense = expense_fixture(%{scope: scope, category: category})

      assert {:error, changeset} = Expenses.delete_expense_category(scope, category)
      assert "are still associated with this entry" in errors_on(changeset).expenses
    end
  end

  describe "expenses" do
    setup do
      %{scope: user_scope_fixture(), other_scope: user_scope_fixture()}
    end

    test "list_expenses/1 returns scoped expenses ordered by date descending and id descending", %{scope: scope, other_scope: other_scope} do
      older = expense_fixture(%{scope: scope, date: ~D[2026-06-20]})
      newer = expense_fixture(%{scope: scope, date: ~D[2026-06-21]})
      _other = expense_fixture(%{scope: other_scope, date: ~D[2026-06-22]})

      assert Expenses.list_expenses(scope) == [newer, older]
    end

    test "get_expense!/2 returns the scoped expense", %{scope: scope, other_scope: other_scope} do
      expense = expense_fixture(%{scope: scope})
      other_expense = expense_fixture(%{scope: other_scope})

      assert Expenses.get_expense!(scope, expense.id).id == expense.id
      assert_raise Ecto.NoResultsError, fn -> Expenses.get_expense!(scope, other_expense.id) end
    end

    test "create_expense/2 with valid data creates an expense for the scoped user", %{scope: scope} do
      category = expense_category_fixture(%{scope: scope})

      valid_attrs = %{
        amount: "125.50",
        currency: "eur",
        date: "2026-06-21",
        category_id: category.id
      }

      assert {:ok, %Expense{} = expense} = Expenses.create_expense(scope, valid_attrs)
      assert expense.amount == Decimal.new("125.50")
      assert expense.created_by == scope.user.email
      assert expense.currency == "EUR"
      assert expense.date == ~D[2026-06-21]
      assert expense.user_id == scope.user.id
    end

    test "create_expense/2 rejects categories from another user", %{scope: scope, other_scope: other_scope} do
      category = expense_category_fixture(%{scope: other_scope})

      assert {:error, changeset} =
               Expenses.create_expense(scope, %{
                 amount: "125.50",
                 currency: "EUR",
                 date: "2026-06-21",
                 category_id: category.id
               })

      assert "is invalid" in errors_on(changeset).category_id
    end

    test "create_expense/2 with invalid data returns error changeset", %{scope: scope} do
      assert {:error, %Ecto.Changeset{}} = Expenses.create_expense(scope, @invalid_expense_attrs)
    end
  end
end
