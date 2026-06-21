defmodule BudgetApp.Users do
  @moduledoc """
  The users context.
  """

  import Ecto.Query, warn: false

  alias BudgetApp.Repo
  alias BudgetApp.Users.User
  alias BudgetApp.Users.UserToken

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: normalize_email(email))
  end

  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = Repo.get_by(User, email: normalize_email(email))

    if User.valid_password?(user, password), do: user
  end

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def create_user(attrs \\ %{}), do: register_user(attrs)

  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false)
  end

  def change_user(%User{} = user, attrs \\ %{}), do: change_user_registration(user, attrs)

  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  def delete_user_session_token(token) do
    Repo.delete_all(from user_token in UserToken, where: user_token.token == ^token and user_token.context == "session")
    :ok
  end

  defp normalize_email(email) do
    email
    |> String.trim()
    |> String.downcase()
  end
end
