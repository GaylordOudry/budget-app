defmodule BudgetAppWeb.UserController do
  use BudgetAppWeb, :controller

  alias BudgetApp.Users
  alias BudgetApp.Users.User

  def home(%Plug.Conn{assigns: %{current_user: %User{}}} = conn, _params) do
    redirect(conn, to: ~p"/expenses")
  end

  def home(conn, _params) do
    redirect(conn, to: ~p"/users")
  end

  def index(conn, _params) do
    render(conn, :index,
      users: Users.list_users(),
      form: Phoenix.Component.to_form(Users.change_user(%User{}))
    )
  end

  def create(conn, %{"user" => user_params}) do
    case Users.create_user(user_params) do
      {:ok, user} ->
        conn
        |> log_in_user(user)
        |> put_flash(:info, "Utilisateur créé avec succès.")
        |> redirect(to: ~p"/expenses")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :index,
          users: Users.list_users(),
          form: Phoenix.Component.to_form(changeset)
        )
    end
  end

  def select(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    conn
    |> log_in_user(user)
    |> put_flash(:info, "#{user.name} est maintenant l'utilisateur actif.")
    |> redirect(to: ~p"/expenses")
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)

    case Users.delete_user(user) do
      {:ok, _user} ->
        conn
        |> maybe_clear_current_user(user)
        |> put_flash(:info, "Utilisateur supprimé avec succès.")
        |> redirect(to: ~p"/users")

      {:error, :user_has_records} ->
        conn
        |> put_flash(:error, "Cet utilisateur possède encore des dépenses, revenus ou catégories.")
        |> redirect(to: ~p"/users")
    end
  end

  defp log_in_user(conn, user) do
    conn
    |> configure_session(renew: true)
    |> put_session(:current_user_id, user.id)
    |> assign(:current_user, user)
  end

  defp maybe_clear_current_user(conn, user) do
    case conn.assigns[:current_user] do
      %User{id: current_user_id} when current_user_id == user.id ->
        conn
        |> configure_session(drop: true)
        |> assign(:current_user, nil)

      _other ->
        conn
    end
  end
end
