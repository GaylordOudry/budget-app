defmodule BudgetAppWeb.IncomeControllerTest do
  use BudgetAppWeb.ConnCase

  import BudgetApp.IncomesFixtures

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
  @invalid_attrs %{amount: nil, currency: nil, date: nil}

  describe "authentication" do
    test "redirects unauthenticated users", %{conn: conn} do
      conn = get(conn, ~p"/incomes")
      assert redirected_to(conn) == ~p"/users/log-in"
    end
  end

  describe "index" do
    setup [:register_and_log_in_user]

    test "lists only the connected user's incomes", %{conn: conn, scope: scope} do
      own_income = income_fixture(%{scope: scope})
      other_income = income_fixture()

      conn = get(conn, ~p"/incomes")
      response = html_response(conn, 200)
      assert response =~ "Liste des revenus"
      assert response =~ own_income.created_by
      refute response =~ other_income.created_by
      assert_navigation_menu(response)
    end
  end

  describe "new income" do
    setup [:register_and_log_in_user]

    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/incomes/new")
      assert html_response(conn, 200) =~ "Nouveau revenu"
    end
  end

  describe "create income" do
    setup [:register_and_log_in_user]

    test "redirects to show when data is valid", %{conn: conn, user: user} do
      conn = post(conn, ~p"/incomes", income: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/incomes/#{id}"

      conn = get(conn, ~p"/incomes/#{id}")
      response = html_response(conn, 200)
      assert response =~ "Revenu #{id}"
      assert response =~ user.email
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/incomes", income: @invalid_attrs)
      assert html_response(conn, 200) =~ "Nouveau revenu"
    end
  end

  describe "edit income" do
    setup [:register_and_log_in_user, :create_income]

    test "renders form for editing chosen income", %{conn: conn, income: income} do
      conn = get(conn, ~p"/incomes/#{income}/edit")
      assert html_response(conn, 200) =~ "Editer le revenu"
    end

    test "returns 404 for another user's income", %{conn: conn} do
      income = income_fixture()

      assert_error_sent 404, fn ->
        get(conn, ~p"/incomes/#{income}")
      end
    end
  end

  describe "update income" do
    setup [:register_and_log_in_user, :create_income]

    test "redirects when data is valid", %{conn: conn, income: income} do
      conn = put(conn, ~p"/incomes/#{income}", income: @update_attrs)

      assert redirected_to(conn) == ~p"/incomes/#{income}"

      conn = get(conn, ~p"/incomes/#{income}")
      response = html_response(conn, 200)
      assert response =~ "300.00"
      assert response =~ "USD"
    end

    test "renders errors when data is invalid", %{conn: conn, income: income} do
      conn = put(conn, ~p"/incomes/#{income}", income: @invalid_attrs)
      assert html_response(conn, 200) =~ "Editer le revenu"
    end
  end

  describe "delete income" do
    setup [:register_and_log_in_user, :create_income]

    test "deletes chosen income", %{conn: conn, income: income} do
      conn = delete(conn, ~p"/incomes/#{income}")
      assert redirected_to(conn) == ~p"/incomes"

      assert_error_sent(404, fn ->
        get(conn, ~p"/incomes/#{income}")
      end)
    end
  end

  defp create_income(%{scope: scope}) do
    income = income_fixture(%{scope: scope})
    %{income: income}
  end
end
