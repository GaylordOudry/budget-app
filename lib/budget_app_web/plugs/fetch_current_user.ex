defmodule BudgetAppWeb.Plugs.FetchCurrentUser do
  import Plug.Conn

  alias BudgetApp.Users

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user =
      conn
      |> get_session(:current_user_id)
      |> case do
        nil -> nil
        user_id -> Users.get_user(user_id)
      end

    conn =
      if current_user do
        conn
      else
        delete_session(conn, :current_user_id)
      end

    assign(conn, :current_user, current_user)
  end
end
