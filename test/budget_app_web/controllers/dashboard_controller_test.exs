defmodule BudgetAppWeb.DashboardControllerTest do
  use BudgetAppWeb.ConnCase

  import BudgetApp.AccountsFixtures
  import BudgetApp.ExpensesFixtures
  import BudgetApp.IncomesFixtures

  describe "authentication" do
    test "redirects unauthenticated users", %{conn: conn} do
      conn = get(conn, ~p"/dashboard")
      assert redirected_to(conn) == ~p"/users/log-in"
    end
  end

  describe "index" do
    setup [:register_and_log_in_user]

    test "shows visible totals and monthly graph data", %{conn: conn, scope: scope} do
      other_scope = user_scope_fixture()

      own_category = expense_category_fixture(%{scope: scope, name: "Maison"})
      shared_category = expense_category_fixture(%{scope: other_scope, name: "Transport", shared: true})
      _private_category = expense_category_fixture(%{scope: other_scope, name: "Secret"})

      _own_income =
        income_fixture(%{
          scope: scope,
          amount: Decimal.new("100.00"),
          date: ~D[2026-01-05]
        })

      _shared_income =
        income_fixture(%{
          scope: other_scope,
          amount: Decimal.new("60.00"),
          date: ~D[2026-02-10],
          shared: true
        })

      _hidden_income =
        income_fixture(%{
          scope: other_scope,
          amount: Decimal.new("500.00"),
          date: ~D[2026-02-20]
        })

      _own_expense =
        expense_fixture(%{
          scope: scope,
          category: own_category,
          amount: Decimal.new("40.00"),
          date: ~D[2026-01-06]
        })

      _shared_expense =
        expense_fixture(%{
          scope: other_scope,
          category: shared_category,
          amount: Decimal.new("20.00"),
          date: ~D[2026-02-12],
          shared: true
        })

      _hidden_expense =
        expense_fixture(%{
          scope: other_scope,
          category: shared_category,
          amount: Decimal.new("900.00"),
          date: ~D[2026-02-15]
        })

      conn = get(conn, ~p"/dashboard")
      response = html_response(conn, 200)

      assert response =~ "Dashboard partagé"
      assert response =~ "160.00 EUR"
      assert response =~ "60.00 EUR"
      assert response =~ "01/2026"
      assert response =~ "02/2026"
      assert response =~ "+60.00 EUR"
      assert response =~ "+40.00 EUR"
      refute response =~ "560.00 EUR"
      refute response =~ "960.00 EUR"
      assert_navigation_menu(response)
    end
  end
end
