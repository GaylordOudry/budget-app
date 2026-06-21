defmodule BudgetAppWeb.UserController do
  use BudgetAppWeb, :controller

  alias BudgetApp.Users
  alias BudgetApp.Users.User
  alias BudgetAppWeb.UserAuth

  def home(%Plug.Conn{assigns: %{current_user: %User{}}} = conn, _params) do
    redirect(conn, to: ~p"/expenses")
  end

  def home(conn, _params) do
    redirect(conn, to: ~p"/users")
  end

  def index(conn, _params) do
    render(conn, :index, registration_form: new_registration_form(), login_form: build_login_form())
  end

  def create(conn, %{"user" => user_params}) do
    case Users.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Compte créé avec succès.")
        |> UserAuth.log_in_user(user)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :index,
          registration_form: Phoenix.Component.to_form(changeset),
          login_form: build_login_form(%{"email" => Map.get(user_params, "email", "")})
        )
    end
  end

  def log_in(conn, %{"user" => %{"email" => email, "password" => password} = user_params}) do
    if user = Users.get_user_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, "Bon retour.")
      |> UserAuth.log_in_user(user, user_params)
    else
      conn
      |> put_flash(:error, "Email ou mot de passe invalide.")
      |> render(:index,
        registration_form: new_registration_form(),
        login_form: build_login_form(%{"email" => email})
      )
    end
  end

  def log_out(conn, _params) do
    conn
    |> put_flash(:info, "Déconnecté avec succès.")
    |> UserAuth.log_out_user()
  end

  defp new_registration_form do
    Phoenix.Component.to_form(Users.change_user_registration(%User{}))
  end

  defp build_login_form(params \\ %{}) do
    Phoenix.Component.to_form(params, as: :user)
  end
end
