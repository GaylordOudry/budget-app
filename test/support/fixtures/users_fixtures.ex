defmodule BudgetApp.UsersFixtures do
  @moduledoc false

  alias BudgetApp.Users

  def user_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "User #{System.unique_integer([:positive])}"
      })

    {:ok, user} = Users.create_user(attrs)
    user
  end
end
