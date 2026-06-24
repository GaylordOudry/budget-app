defmodule BudgetAppWeb.ExpenseCategoryControllerTest do
  use BudgetAppWeb.ConnCase

  import BudgetApp.ExpensesFixtures

  @create_attrs %{name: "Housing"}
  @update_attrs %{name: "Transport"}
  @invalid_attrs %{name: nil}

  describe "authentication" do
    test "redirects unauthenticated users", %{conn: conn} do
      conn = get(conn, ~p"/categories")
      assert redirected_to(conn) == ~p"/users/log-in"
    end
  end

  describe "index" do
    setup [:register_and_log_in_user]

    test "lists only the connected user's categories", %{conn: conn, scope: scope} do
      _own_category = expense_category_fixture(%{scope: scope, name: "Housing"})
      _other_category = expense_category_fixture(%{name: "Travel"})

      conn = get(conn, ~p"/categories")
      response = html_response(conn, 200)
      assert response =~ "Liste des catégories"
      assert response =~ "Housing"
      refute response =~ "Travel"
      assert_navigation_menu(response)
    end
  end

  describe "new category" do
    setup [:register_and_log_in_user]

    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/categories/new")
      assert html_response(conn, 200) =~ "Nouvelle catégorie"
    end
  end

  describe "create category" do
    setup [:register_and_log_in_user]

    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/categories", expense_category: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/categories/#{id}"

      conn = get(conn, ~p"/categories/#{id}")
      assert html_response(conn, 200) =~ "Housing"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/categories", expense_category: @invalid_attrs)
      assert html_response(conn, 200) =~ "Nouvelle catégorie"
    end
  end

  describe "edit category" do
    setup [:register_and_log_in_user, :create_category]

    test "renders form for editing chosen category", %{conn: conn, category: category} do
      conn = get(conn, ~p"/categories/#{category}/edit")
      assert html_response(conn, 200) =~ "Editer la catégorie"
    end

    test "returns 404 for another user's category", %{conn: conn} do
      category = expense_category_fixture()

      assert_error_sent 404, fn ->
        get(conn, ~p"/categories/#{category}")
      end
    end
  end

  describe "update category" do
    setup [:register_and_log_in_user, :create_category]

    test "redirects when data is valid", %{conn: conn, category: category} do
      conn = put(conn, ~p"/categories/#{category}", expense_category: @update_attrs)
      assert redirected_to(conn) == ~p"/categories/#{category}"

      conn = get(conn, ~p"/categories/#{category}")
      assert html_response(conn, 200) =~ "Transport"
    end

    test "renders errors when data is invalid", %{conn: conn, category: category} do
      conn = put(conn, ~p"/categories/#{category}", expense_category: @invalid_attrs)
      assert html_response(conn, 200) =~ "Editer la catégorie"
    end
  end

  describe "delete category" do
    setup [:register_and_log_in_user, :create_category]

    test "deletes chosen category", %{conn: conn, category: category} do
      conn = delete(conn, ~p"/categories/#{category}")
      assert redirected_to(conn) == ~p"/categories"

      assert_error_sent(404, fn ->
        get(conn, ~p"/categories/#{category}")
      end)
    end

    test "shows an error when expenses still reference the category", %{
      conn: conn,
      category: category,
      scope: scope
    } do
      _expense = expense_fixture(%{scope: scope, category: category})

      conn = delete(conn, ~p"/categories/#{category}")

      assert redirected_to(conn) == ~p"/categories/#{category}"

      conn = get(recycle(conn), ~p"/categories/#{category}")

      assert html_response(conn, 200) =~
               "Category could not be deleted because expenses still reference it."
    end
  end

  defp create_category(%{scope: scope}) do
    category = expense_category_fixture(%{scope: scope})
    %{category: category}
  end
end
