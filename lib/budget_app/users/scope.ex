defmodule BudgetApp.Users.Scope do
  @moduledoc """
  Scope data for the authenticated user.
  """

  alias BudgetApp.Users.User

  defstruct user: nil

  def for_user(%User{} = user), do: %__MODULE__{user: user}
  def for_user(nil), do: nil
end
