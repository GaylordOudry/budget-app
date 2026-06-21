defmodule BudgetApp.IncomesTest do
  use BudgetApp.DataCase, async: true

  import BudgetApp.IncomesFixtures

  alias BudgetApp.Incomes
  alias BudgetApp.Incomes.Income

  @invalid_attrs %{amount: nil, created_by: nil, currency: nil, date: nil}

  describe "incomes" do
    test "list_incomes/1 returns incomes ordered by date descending and id descending" do
      older = income_fixture(%{date: ~D[2026-06-20], created_by: "owner"})
      newer = income_fixture(%{date: ~D[2026-06-21], created_by: "owner"})
      _other = income_fixture(%{date: ~D[2026-06-22], created_by: "reviewer"})

      assert Incomes.list_incomes("owner") == [newer, older]
    end

    test "get_income!/2 returns the income with given id" do
      income = income_fixture(%{created_by: "owner"})

      assert Incomes.get_income!(income.id, "owner") == income
    end

    test "create_income/2 with valid data creates an income" do
      valid_attrs = %{
        amount: "125.50",
        currency: "eur",
        date: "2026-06-21"
      }

      assert {:ok, %Income{} = income} = Incomes.create_income(valid_attrs, "owner")
      assert income.amount == Decimal.new("125.50")
      assert income.created_by == "owner"
      assert income.currency == "EUR"
      assert income.date == ~D[2026-06-21]
    end

    test "create_income/2 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Incomes.create_income(@invalid_attrs, "owner")
    end

    test "update_income/2 with valid data updates the income" do
      income = income_fixture(%{created_by: "owner"})

      update_attrs = %{
        amount: "300.00",
        currency: "usd",
        date: "2026-06-22"
      }

      assert {:ok, %Income{} = income} = Incomes.update_income(income, update_attrs, "owner")
      assert income.amount == Decimal.new("300.00")
      assert income.created_by == "owner"
      assert income.currency == "USD"
      assert income.date == ~D[2026-06-22]
    end

    test "update_income/2 with invalid data returns error changeset" do
      income = income_fixture(%{created_by: "owner"})

      assert {:error, %Ecto.Changeset{}} = Incomes.update_income(income, @invalid_attrs, "owner")
      assert income == Incomes.get_income!(income.id, "owner")
    end

    test "delete_income/1 deletes the income" do
      income = income_fixture(%{created_by: "owner"})
      assert {:ok, %Income{}} = Incomes.delete_income(income)
      assert_raise Ecto.NoResultsError, fn -> Incomes.get_income!(income.id, "owner") end
    end

    test "change_income/1 returns an income changeset" do
      income = income_fixture(%{created_by: "owner"})
      assert %Ecto.Changeset{} = Incomes.change_income(income)
    end
  end
end
