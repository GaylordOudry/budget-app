defmodule BudgetApp.UsersFixtures do
  @moduledoc false

  alias BudgetApp.Users

  def unique_user_email, do: "user#{System.unique_integer([:positive])}@example.com"
  def valid_user_password, do: "hello world!"

  def user_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "User #{System.unique_integer([:positive])}",
        email: unique_user_email(),
        password: valid_user_password()
      })

    {:ok, user} = Users.register_user(attrs)
    user
  end
end
