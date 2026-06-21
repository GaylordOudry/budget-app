defmodule BudgetAppWeb.UserControllerTest do
  use BudgetAppWeb.ConnCase

  import BudgetApp.ExpensesFixtures

  @create_attrs %{name: "Alice"}
  @invalid_attrs %{name: ""}

  describe "index" do
    test "lists users", %{conn: conn} do
      conn = get(conn, ~p"/users")
      assert html_response(conn, 200) =~ "Utilisateurs"
    end
  end

  describe "create" do
    test "creates a user and selects it", %{conn: conn} do
      conn = post(conn, ~p"/users", user: @create_attrs)

      assert redirected_to(conn) == ~p"/expenses"
      assert get_session(conn, :current_user_id)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/users", user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Utilisateurs"
    end
  end

  describe "select" do
    test "switches the active user", %{conn: conn} do
      user = user_fixture(%{name: "Reviewer"})

      conn = post(conn, ~p"/users/#{user}/select")

      assert redirected_to(conn) == ~p"/expenses"
      assert get_session(conn, :current_user_id) == user.id
    end
  end

  describe "delete" do
    test "deletes a user without records", %{conn: conn} do
      user = user_fixture(%{name: "Reviewer"})

      conn = delete(conn, ~p"/users/#{user}")

      assert redirected_to(conn) == ~p"/users"
    end

    test "keeps a user with records", %{conn: conn} do
      user = user_fixture(%{name: "Reviewer"})
      _category = expense_category_fixture(%{created_by: user.name})

      conn = delete(conn, ~p"/users/#{user}")

      assert redirected_to(conn) == ~p"/users"
      conn = get(recycle(conn), ~p"/users")
      assert html_response(conn, 200) =~ "possède encore"
    end
  end
end
