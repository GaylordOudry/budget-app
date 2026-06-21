defmodule BudgetAppWeb.UserControllerTest do
  use BudgetAppWeb.ConnCase

  import BudgetApp.UsersFixtures

  @create_attrs %{name: "Alice", email: "alice@example.com", password: "hello world!"}
  @invalid_attrs %{name: "", email: "invalid", password: "short"}

  describe "index" do
    test "renders authentication forms", %{conn: conn} do
      conn = get(conn, ~p"/users")
      html = html_response(conn, 200)
      assert html =~ "Connexion sécurisée"
      assert html =~ "Créer un compte"
    end
  end

  describe "create" do
    test "creates a user and logs it in", %{conn: conn} do
      conn = post(conn, ~p"/users", user: @create_attrs)

      assert redirected_to(conn) == ~p"/expenses"
      assert get_session(conn, :user_token)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/users", user: @invalid_attrs)
      assert html_response(conn, 200) =~ "Créer un compte"
    end
  end

  describe "log in" do
    test "authenticates an existing user", %{conn: conn} do
      user = user_fixture(%{name: "Reviewer", email: "reviewer@example.com"})

      conn =
        post(conn, ~p"/users/log-in",
          user: %{email: user.email, password: valid_user_password(), remember_me: "true"}
        )

      assert redirected_to(conn) == ~p"/expenses"
      assert get_session(conn, :user_token)
    end

    test "renders an error for invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/users/log-in",
          user: %{email: "missing@example.com", password: valid_user_password()}
        )

      assert html_response(conn, 200) =~ "Email ou mot de passe invalide."
    end
  end

  describe "log out" do
    test "clears the session", %{conn: conn} do
      user = user_fixture(%{name: "Reviewer", email: "reviewer@example.com"})
      conn = log_in_user(conn, user)

      conn = delete(conn, ~p"/users/log-out")

      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :user_token)
    end
  end
end
