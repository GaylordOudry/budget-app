defmodule BudgetApp.IncomesTest do
  use BudgetApp.DataCase, async: true

  import BudgetApp.AccountsFixtures
  import BudgetApp.IncomesFixtures

  alias BudgetApp.Incomes
  alias BudgetApp.Incomes.Income

  @invalid_attrs %{amount: nil, currency: nil, date: nil}

  describe "incomes" do
    setup do
      %{scope: user_scope_fixture(), other_scope: user_scope_fixture()}
    end

    test "list_incomes/1 returns scoped incomes ordered by date descending and id descending", %{scope: scope, other_scope: other_scope} do
      older = income_fixture(%{scope: scope, date: ~D[2026-06-20]})
      newer = income_fixture(%{scope: scope, date: ~D[2026-06-21]})
      _other = income_fixture(%{scope: other_scope, date: ~D[2026-06-22]})

      assert Incomes.list_incomes(scope) == [newer, older]
    end

    test "get_income!/2 returns the scoped income with given id", %{scope: scope, other_scope: other_scope} do
      income = income_fixture(%{scope: scope})
      other_income = income_fixture(%{scope: other_scope})

      assert Incomes.get_income!(scope, income.id) == income
      assert_raise Ecto.NoResultsError, fn -> Incomes.get_income!(scope, other_income.id) end
    end

    test "create_income/2 with valid data creates an income for the scoped user", %{scope: scope} do
      valid_attrs = %{
        amount: "125.50",
        currency: "eur",
        date: "2026-06-21"
      }

      assert {:ok, %Income{} = income} = Incomes.create_income(scope, valid_attrs)
      assert income.amount == Decimal.new("125.50")
      assert income.created_by == scope.user.email
      assert income.currency == "EUR"
      assert income.date == ~D[2026-06-21]
      assert income.user_id == scope.user.id
    end

    test "create_income/2 with invalid data returns error changeset", %{scope: scope} do
      assert {:error, %Ecto.Changeset{}} = Incomes.create_income(scope, @invalid_attrs)
    end

    test "update_income/3 with valid data updates the income", %{scope: scope} do
      income = income_fixture(%{scope: scope})

      update_attrs = %{
        amount: "300.00",
        currency: "usd",
        date: "2026-06-22"
      }

      assert {:ok, %Income{} = income} = Incomes.update_income(scope, income, update_attrs)
      assert income.amount == Decimal.new("300.00")
      assert income.created_by == scope.user.email
      assert income.currency == "USD"
      assert income.date == ~D[2026-06-22]
    end

    test "update_income/3 with invalid data returns error changeset", %{scope: scope} do
      income = income_fixture(%{scope: scope})

      assert {:error, %Ecto.Changeset{}} = Incomes.update_income(scope, income, @invalid_attrs)
      assert income == Incomes.get_income!(scope, income.id)
    end

    test "delete_income/2 deletes the income", %{scope: scope} do
      income = income_fixture(%{scope: scope})
      assert {:ok, %Income{}} = Incomes.delete_income(scope, income)
      assert_raise Ecto.NoResultsError, fn -> Incomes.get_income!(scope, income.id) end
    end

    test "change_income/2 returns an income changeset", %{scope: scope} do
      income = income_fixture(%{scope: scope})
      assert %Ecto.Changeset{} = Incomes.change_income(scope, income)
    end
  end
end
