defmodule BudgetAppWeb.ExpenseCategoryControllerTest do
  use BudgetAppWeb.ConnCase

  import BudgetApp.ExpensesFixtures

  @create_attrs %{name: "Housing"}
  @update_attrs %{name: "Transport"}
  @invalid_attrs %{name: nil}

  describe "index" do
    test "lists all categories", %{conn: conn} do
      conn = get(conn, ~p"/categories")
      response = html_response(conn, 200)
      assert response =~ "Listing categories"
      assert_navigation_menu(response)
    end
  end

  describe "new category" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/categories/new")
      assert html_response(conn, 200) =~ "New category"
    end
  end

  describe "create category" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/categories", expense_category: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/categories/#{id}"

      conn = get(conn, ~p"/categories/#{id}")
      assert html_response(conn, 200) =~ "Housing"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/categories", expense_category: @invalid_attrs)
      assert html_response(conn, 200) =~ "New category"
    end
  end

  describe "edit category" do
    setup [:create_category]

    test "renders form for editing chosen category", %{conn: conn, category: category} do
      conn = get(conn, ~p"/categories/#{category}/edit")
      assert html_response(conn, 200) =~ "Edit category"
    end
  end

  describe "update category" do
    setup [:create_category]

    test "redirects when data is valid", %{conn: conn, category: category} do
      conn = put(conn, ~p"/categories/#{category}", expense_category: @update_attrs)
      assert redirected_to(conn) == ~p"/categories/#{category}"

      conn = get(conn, ~p"/categories/#{category}")
      assert html_response(conn, 200) =~ "Transport"
    end

    test "renders errors when data is invalid", %{conn: conn, category: category} do
      conn = put(conn, ~p"/categories/#{category}", expense_category: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit category"
    end
  end

  describe "delete category" do
    setup [:create_category]

    test "deletes chosen category", %{conn: conn, category: category} do
      conn = delete(conn, ~p"/categories/#{category}")
      assert redirected_to(conn) == ~p"/categories"

      assert_error_sent 404, fn ->
        get(conn, ~p"/categories/#{category}")
      end
    end

    test "shows an error when expenses still reference the category", %{conn: conn, category: category} do
      _expense = expense_fixture(%{category: category})

      conn = delete(conn, ~p"/categories/#{category}")

      assert redirected_to(conn) == ~p"/categories/#{category}"

      conn = get(recycle(conn), ~p"/categories/#{category}")
      assert html_response(conn, 200) =~ "Category could not be deleted because expenses still reference it."
    end
  end

  defp create_category(_) do
    category = expense_category_fixture()
    %{category: category}
  end

  defp assert_navigation_menu(response) do
    assert response =~ ~s(id="app-navigation")
    assert response =~ ~s(href="/expenses")
    assert response =~ ~s(href="/incomes")
    assert response =~ ~s(href="/categories")
  end
end
