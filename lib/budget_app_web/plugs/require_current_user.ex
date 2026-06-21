defmodule BudgetAppWeb.Plugs.RequireCurrentUser do
  import Phoenix.Controller
  import Plug.Conn

  use BudgetAppWeb, :verified_routes

  alias BudgetApp.Users.User

  def init(opts), do: opts

  def call(%Plug.Conn{assigns: %{current_user: %User{}}} = conn, _opts), do: conn

  def call(conn, _opts) do
    conn
    |> put_flash(:error, "Sélectionnez un utilisateur pour continuer.")
    |> redirect(to: ~p"/users")
    |> halt()
  end
end
