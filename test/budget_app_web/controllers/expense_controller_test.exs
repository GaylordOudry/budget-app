defmodule BudgetAppWeb.ExpenseControllerTest do
  use BudgetAppWeb.ConnCase

  import BudgetApp.ExpensesFixtures

  @create_attrs %{
    amount: "125.50",
    created_by: "owner",
    currency: "EUR",
    date: "2026-06-21"
  }
  @update_attrs %{
    amount: "300.00",
    created_by: "reviewer",
    currency: "usd",
    date: "2026-06-22"
  }
  @invalid_attrs %{amount: nil, created_by: nil, currency: nil, date: nil, category_id: nil}

  describe "index" do
    test "lists all expenses", %{conn: conn} do
      conn = get(conn, ~p"/expenses")
      assert html_response(conn, 200) =~ "Listing expenses"
    end
  end

  describe "new expense" do
    test "renders form", %{conn: conn} do
      _category = expense_category_fixture()

      conn = get(conn, ~p"/expenses/new")
      assert html_response(conn, 200) =~ "New expense"
    end
  end

  describe "create expense" do
    test "redirects to show when data is valid", %{conn: conn} do
      category = expense_category_fixture()

      conn =
        post(conn, ~p"/expenses", expense: Map.put(@create_attrs, :category_id, category.id))

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/expenses/#{id}"

      conn = get(conn, ~p"/expenses/#{id}")
      assert html_response(conn, 200) =~ "Expense #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/expenses", expense: @invalid_attrs)
      assert html_response(conn, 200) =~ "New expense"
    end
  end

  describe "edit expense" do
    setup [:create_expense]

    test "renders form for editing chosen expense", %{conn: conn, expense: expense} do
      conn = get(conn, ~p"/expenses/#{expense}/edit")
      assert html_response(conn, 200) =~ "Edit expense"
    end
  end

  describe "update expense" do
    setup [:create_expense]

    test "redirects when data is valid", %{conn: conn, expense: expense} do
      category = expense_category_fixture()

      conn =
        put(conn, ~p"/expenses/#{expense}", expense: Map.put(@update_attrs, :category_id, category.id))

      assert redirected_to(conn) == ~p"/expenses/#{expense}"

      conn = get(conn, ~p"/expenses/#{expense}")
      response = html_response(conn, 200)
      assert response =~ "300.00"
      assert response =~ "USD"
      assert response =~ "reviewer"
    end

    test "renders errors when data is invalid", %{conn: conn, expense: expense} do
      conn = put(conn, ~p"/expenses/#{expense}", expense: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit expense"
    end
  end

  describe "delete expense" do
    setup [:create_expense]

    test "deletes chosen expense", %{conn: conn, expense: expense} do
      conn = delete(conn, ~p"/expenses/#{expense}")
      assert redirected_to(conn) == ~p"/expenses"

      assert_error_sent 404, fn ->
        get(conn, ~p"/expenses/#{expense}")
      end
    end
  end

  defp create_expense(_) do
    expense = expense_fixture()
    %{expense: expense}
  end
end
