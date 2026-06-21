defmodule BudgetAppWeb.UserAuth do
  use BudgetAppWeb, :verified_routes

  import BudgetAppWeb.Gettext
  import Phoenix.Controller
  import Plug.Conn

  alias BudgetApp.Users
  alias BudgetApp.Users.Scope

  @max_cookie_age 14 * 24 * 60 * 60
  @remember_me_cookie "_budget_app_user_remember_me"
  @remember_me_options [sign: true, max_age: @max_cookie_age, same_site: "Lax"]

  def log_in_user(conn, user, params \\ %{}) do
    user_return_to = get_session(conn, :user_return_to)
    token = Users.generate_user_session_token(user)

    conn
    |> renew_session()
    |> put_token_in_session(token)
    |> maybe_write_remember_me_cookie(token, params)
    |> assign(:current_scope, Scope.for_user(user))
    |> assign(:current_user, user)
    |> redirect(to: user_return_to || signed_in_path(conn))
  end

  def log_out_user(conn) do
    if token = get_session(conn, :user_token) do
      Users.delete_user_session_token(token)
    end

    conn
    |> renew_session()
    |> delete_resp_cookie(@remember_me_cookie, @remember_me_options)
    |> assign(:current_scope, nil)
    |> assign(:current_user, nil)
    |> redirect(to: ~p"/")
  end

  def fetch_current_scope_for_user(conn, _opts) do
    case ensure_user_token(conn) do
      {token, conn} ->
        case Users.get_user_by_session_token(token) do
          {user, _inserted_at} ->
            conn
            |> assign(:current_scope, Scope.for_user(user))
            |> assign(:current_user, user)

          nil ->
            conn
            |> delete_session(:user_token)
            |> assign(:current_scope, nil)
            |> assign(:current_user, nil)
        end

      {nil, conn} ->
        conn
        |> assign(:current_scope, nil)
        |> assign(:current_user, nil)
    end
  end

  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns.current_user do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  def require_authenticated_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, gettext("Connectez-vous pour accéder à cette page."))
      |> maybe_store_return_to()
      |> redirect(to: ~p"/users")
      |> halt()
    end
  end

  defp ensure_user_token(conn) do
    if token = get_session(conn, :user_token) do
      {token, conn}
    else
      conn = fetch_cookies(conn, signed: [@remember_me_cookie])

      if token = conn.cookies[@remember_me_cookie] do
        {token, put_session(conn, :user_token, token)}
      else
        {nil, conn}
      end
    end
  end

  defp renew_session(conn) do
    delete_csrf_token()

    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  defp put_token_in_session(conn, token), do: put_session(conn, :user_token, token)

  defp maybe_write_remember_me_cookie(conn, token, %{"remember_me" => "true"}) do
    conn
    |> put_session(:user_remember_me, true)
    |> put_resp_cookie(@remember_me_cookie, token, @remember_me_options)
  end

  defp maybe_write_remember_me_cookie(conn, _token, _params), do: conn

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    put_session(conn, :user_return_to, current_path(conn))
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(_conn), do: ~p"/expenses"
end
