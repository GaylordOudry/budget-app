defmodule BudgetAppWeb.PageControllerTest do
  use BudgetAppWeb.ConnCase

  test "GET / redirects guests to the login page", %{conn: conn} do
    conn = get(conn, ~p"/")

    assert redirected_to(conn) == ~p"/users/log-in"
  end

  test "GET / redirects authenticated users to expenses", %{conn: conn} do
    conn =
      conn
      |> log_in_user(user_fixture())
      |> get(~p"/")

    assert redirected_to(conn) == ~p"/dashboard"
  end
end
