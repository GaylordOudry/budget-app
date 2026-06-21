defmodule BudgetApp.IncomesTest do
  use BudgetApp.DataCase, async: true

  import BudgetApp.IncomesFixtures

  alias BudgetApp.Incomes
  alias BudgetApp.Incomes.Income

  @invalid_attrs %{amount: nil, created_by: nil, currency: nil, date: nil}

  describe "incomes" do
    test "list_incomes/0 returns incomes ordered by date descending and id descending" do
      older = income_fixture(%{date: ~D[2026-06-20]})
      newer = income_fixture(%{date: ~D[2026-06-21]})

      assert Incomes.list_incomes() == [newer, older]
    end

    test "get_income!/1 returns the income with given id" do
      income = income_fixture()

      assert Incomes.get_income!(income.id) == income
    end

    test "create_income/1 with valid data creates an income" do
      valid_attrs = %{
        amount: "125.50",
        created_by: "owner",
        currency: "eur",
        date: "2026-06-21"
      }

      assert {:ok, %Income{} = income} = Incomes.create_income(valid_attrs)
      assert income.amount == Decimal.new("125.50")
      assert income.created_by == "owner"
      assert income.currency == "EUR"
      assert income.date == ~D[2026-06-21]
    end

    test "create_income/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Incomes.create_income(@invalid_attrs)
    end

    test "update_income/2 with valid data updates the income" do
      income = income_fixture()

      update_attrs = %{
        amount: "300.00",
        created_by: "reviewer",
        currency: "usd",
        date: "2026-06-22"
      }

      assert {:ok, %Income{} = income} = Incomes.update_income(income, update_attrs)
      assert income.amount == Decimal.new("300.00")
      assert income.created_by == "reviewer"
      assert income.currency == "USD"
      assert income.date == ~D[2026-06-22]
    end

    test "update_income/2 with invalid data returns error changeset" do
      income = income_fixture()

      assert {:error, %Ecto.Changeset{}} = Incomes.update_income(income, @invalid_attrs)
      assert income == Incomes.get_income!(income.id)
    end

    test "delete_income/1 deletes the income" do
      income = income_fixture()
      assert {:ok, %Income{}} = Incomes.delete_income(income)
      assert_raise Ecto.NoResultsError, fn -> Incomes.get_income!(income.id) end
    end

    test "change_income/1 returns an income changeset" do
      income = income_fixture()
      assert %Ecto.Changeset{} = Incomes.change_income(income)
    end
  end
end
