defmodule BudgetAppWeb.ExpenseControllerTest do
  use BudgetAppWeb.ConnCase

  import BudgetApp.ExpensesFixtures

  @create_attrs %{
    amount: "125.50",
    currency: "EUR",
    date: "2026-06-21"
  }
  @update_attrs %{
    amount: "300.00",
    currency: "usd",
    date: "2026-06-22"
  }
  @invalid_attrs %{amount: nil, currency: nil, date: nil, category_id: nil}

  describe "authentication" do
    test "redirects unauthenticated users", %{conn: conn} do
      conn = get(conn, ~p"/expenses")
      assert redirected_to(conn) == ~p"/users/log-in"
    end
  end

  describe "index" do
    setup [:register_and_log_in_user]

    test "lists only the connected user's expenses", %{conn: conn, scope: scope} do
      own_category = expense_category_fixture(%{scope: scope, name: "Groceries"})
      _own_expense = expense_fixture(%{scope: scope, category: own_category})
      other_category = expense_category_fixture(%{name: "Travel"})
      _other_expense = expense_fixture(%{category: other_category})

      conn = get(conn, ~p"/expenses")
      response = html_response(conn, 200)
      assert response =~ "Liste des dépenses"
      assert response =~ "Groceries"
      refute response =~ "Travel"
      assert_navigation_menu(response)
    end
  end

  describe "new expense" do
    setup [:register_and_log_in_user]

    test "renders form with the current user's categories only", %{conn: conn, scope: scope} do
      _own_category = expense_category_fixture(%{scope: scope, name: "Groceries"})
      _other_category = expense_category_fixture(%{name: "Travel"})

      conn = get(conn, ~p"/expenses/new")
      response = html_response(conn, 200)
      assert response =~ "Nouvelle dépense"
      assert response =~ "Groceries"
      refute response =~ "Travel"
    end
  end

  describe "create expense" do
    setup [:register_and_log_in_user]

    test "redirects to show when data is valid", %{conn: conn, scope: scope, user: user} do
      category = expense_category_fixture(%{scope: scope})

      conn =
        post(conn, ~p"/expenses", expense: Map.put(@create_attrs, :category_id, category.id))

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/expenses/#{id}"

      conn = get(conn, ~p"/expenses/#{id}")
      response = html_response(conn, 200)
      assert response =~ "Dépense #{id}"
      assert response =~ user.email
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/expenses", expense: @invalid_attrs)
      assert html_response(conn, 200) =~ "Nouvelle dépense"
    end
  end

  describe "edit expense" do
    setup [:register_and_log_in_user, :create_expense]

    test "renders form for editing chosen expense", %{conn: conn, expense: expense} do
      conn = get(conn, ~p"/expenses/#{expense}/edit")
      assert html_response(conn, 200) =~ "Editer la dépense"
    end

    test "returns 404 for another user's expense", %{conn: conn} do
      expense = expense_fixture()

      assert_error_sent 404, fn ->
        get(conn, ~p"/expenses/#{expense}")
      end
    end
  end

  describe "update expense" do
    setup [:register_and_log_in_user, :create_expense]

    test "redirects when data is valid", %{conn: conn, expense: expense, scope: scope} do
      category = expense_category_fixture(%{scope: scope})

      conn =
        put(conn, ~p"/expenses/#{expense}",
          expense: Map.put(@update_attrs, :category_id, category.id)
        )

      assert redirected_to(conn) == ~p"/expenses/#{expense}"

      conn = get(conn, ~p"/expenses/#{expense}")
      response = html_response(conn, 200)
      assert response =~ "300.00"
      assert response =~ "USD"
    end

    test "renders errors when data is invalid", %{conn: conn, expense: expense} do
      conn = put(conn, ~p"/expenses/#{expense}", expense: @invalid_attrs)
      assert html_response(conn, 200) =~ "Editer la dépense"
    end
  end

  describe "delete expense" do
    setup [:register_and_log_in_user, :create_expense]

    test "deletes chosen expense", %{conn: conn, expense: expense} do
      conn = delete(conn, ~p"/expenses/#{expense}")
      assert redirected_to(conn) == ~p"/expenses"

      assert_error_sent(404, fn ->
        get(conn, ~p"/expenses/#{expense}")
      end)
    end
  end

  defp create_expense(%{scope: scope}) do
    expense = expense_fixture(%{scope: scope})
    %{expense: expense}
  end
end
