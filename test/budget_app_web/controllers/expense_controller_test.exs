defmodule BudgetAppWeb.ExpenseControllerTest do
  use BudgetAppWeb.ConnCase

  import BudgetApp.AccountsFixtures
  import BudgetApp.ExpensesFixtures

  @create_attrs %{
    amount: "125.50",
    currency: "EUR",
    date: "2026-06-21",
    shared: "true"
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

    test "lists the connected user's expenses and shared expenses", %{conn: conn, scope: scope} do
      other_scope = user_scope_fixture()
      own_category = expense_category_fixture(%{scope: scope, name: "Groceries"})
      _own_expense = expense_fixture(%{scope: scope, category: own_category})
      shared_category = expense_category_fixture(%{scope: other_scope, name: "Transport", shared: true})
      _shared_expense = expense_fixture(%{scope: other_scope, category: shared_category, shared: true})
      other_category = expense_category_fixture(%{scope: other_scope, name: "Travel"})
      _other_expense = expense_fixture(%{scope: other_scope, category: other_category, shared: false})

      conn = get(conn, ~p"/expenses")
      response = html_response(conn, 200)
      assert response =~ "Liste des dépenses"
      assert response =~ "Groceries"
      assert response =~ "Transport"
      refute response =~ "Travel"
      assert_navigation_menu(response)
    end
  end

  describe "new expense" do
    setup [:register_and_log_in_user]

    test "renders form with owned and shared categories only", %{conn: conn, scope: scope} do
      other_scope = user_scope_fixture()
      _own_category = expense_category_fixture(%{scope: scope, name: "Groceries"})
      _shared_category = expense_category_fixture(%{scope: other_scope, name: "Transport", shared: true})
      _other_category = expense_category_fixture(%{scope: other_scope, name: "Travel", shared: false})

      conn = get(conn, ~p"/expenses/new")
      response = html_response(conn, 200)
      assert response =~ "Nouvelle dépense"
      assert response =~ "Groceries"
      assert response =~ "Transport"
      refute response =~ "Travel"
      assert response =~ "Partager cette dépense"
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
      assert response =~ "Partagé"
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

    test "returns 404 when editing another user's shared expense", %{conn: conn} do
      expense = expense_fixture(%{shared: true})

      assert_error_sent 404, fn ->
        get(conn, ~p"/expenses/#{expense}/edit")
      end
    end
  end

  describe "show shared expense" do
    setup [:register_and_log_in_user]

    test "renders another user's shared expense without edit actions", %{conn: conn} do
      expense = expense_fixture(%{shared: true})

      conn = get(conn, ~p"/expenses/#{expense}")
      response = html_response(conn, 200)

      assert response =~ "Dépense #{expense.id}"
      assert response =~ "Partagé"
      refute response =~ ~p"/expenses/#{expense}/edit"
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
