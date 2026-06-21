defmodule BudgetAppWeb.PageControllerTest do
  use BudgetAppWeb.ConnCase

  test "GET / redirects to users when no user is authenticated", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert redirected_to(conn) == ~p"/users"
  end

  test "GET / redirects to expenses when a user is authenticated", %{conn: conn} do
    %{conn: conn} = register_and_log_in_user(%{conn: conn})
    conn = get(conn, ~p"/")

    assert redirected_to(conn) == ~p"/expenses"
  end
end
