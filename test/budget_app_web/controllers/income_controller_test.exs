defmodule BudgetAppWeb.IncomeControllerTest do
  use BudgetAppWeb.ConnCase

  import BudgetApp.IncomesFixtures

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
  @invalid_attrs %{amount: nil, created_by: nil, currency: nil, date: nil}

  describe "index" do
    test "lists all incomes", %{conn: conn} do
      conn = get(conn, ~p"/incomes")
      response = html_response(conn, 200)
      assert response =~ "Listing incomes"
      assert_navigation_menu(response)
    end
  end

  describe "new income" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/incomes/new")
      assert html_response(conn, 200) =~ "New income"
    end
  end

  describe "create income" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/incomes", income: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/incomes/#{id}"

      conn = get(conn, ~p"/incomes/#{id}")
      assert html_response(conn, 200) =~ "Income #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/incomes", income: @invalid_attrs)
      assert html_response(conn, 200) =~ "New income"
    end
  end

  describe "edit income" do
    setup [:create_income]

    test "renders form for editing chosen income", %{conn: conn, income: income} do
      conn = get(conn, ~p"/incomes/#{income}/edit")
      assert html_response(conn, 200) =~ "Edit income"
    end
  end

  describe "update income" do
    setup [:create_income]

    test "redirects when data is valid", %{conn: conn, income: income} do
      conn = put(conn, ~p"/incomes/#{income}", income: @update_attrs)

      assert redirected_to(conn) == ~p"/incomes/#{income}"

      conn = get(conn, ~p"/incomes/#{income}")
      response = html_response(conn, 200)
      assert response =~ "300.00"
      assert response =~ "USD"
      assert response =~ "reviewer"
    end

    test "renders errors when data is invalid", %{conn: conn, income: income} do
      conn = put(conn, ~p"/incomes/#{income}", income: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit income"
    end
  end

  describe "delete income" do
    setup [:create_income]

    test "deletes chosen income", %{conn: conn, income: income} do
      conn = delete(conn, ~p"/incomes/#{income}")
      assert redirected_to(conn) == ~p"/incomes"

      assert_error_sent 404, fn ->
        get(conn, ~p"/incomes/#{income}")
      end
    end
  end

  defp create_income(_) do
    income = income_fixture()
    %{income: income}
  end

  defp assert_navigation_menu(response) do
    assert response =~ ~s(id="app-navigation")
    assert response =~ ~s(href="/expenses")
    assert response =~ ~s(href="/incomes")
    assert response =~ ~s(href="/categories")
  end
end
