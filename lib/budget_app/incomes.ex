defmodule BudgetApp.Incomes do
  @moduledoc """
  The incomes context.
  """

  import Ecto.Query, warn: false

  alias BudgetApp.Accounts.Scope
  alias BudgetApp.Accounts.User
  alias BudgetApp.Incomes.Income
  alias BudgetApp.Repo

  def list_incomes(scope) do
    Income
    |> visible_to_scope(scope)
    |> order_by([income], [desc: income.date, desc: income.id])
    |> Repo.all()
  end

  def get_income!(scope, id) do
    Income
    |> visible_to_scope(scope)
    |> where([income], income.id == ^id)
    |> Repo.one!()
  end

  def get_owned_income!(scope, id) do
    Income
    |> owned_by_scope(scope)
    |> where([income], income.id == ^id)
    |> Repo.one!()
  end

  def create_income(scope, attrs \\ %{}) do
    %Income{}
    |> Income.changeset(attrs, scope_user(scope))
    |> Repo.insert()
  end

  def update_income(scope, %Income{} = income, attrs) do
    income
    |> ensure_owned_by!(scope)
    |> Income.changeset(attrs, scope_user(scope))
    |> Repo.update()
  end

  def delete_income(scope, %Income{} = income) do
    income
    |> ensure_owned_by!(scope)
    |> Repo.delete()
  end

  def change_income(scope, %Income{} = income, attrs \\ %{}) do
    income
    |> maybe_ensure_owned_by(scope)
    |> Income.changeset(attrs, scope_user(scope))
  end

  defp maybe_ensure_owned_by(%schema{id: nil} = struct, _scope) when is_atom(schema), do: struct
  defp maybe_ensure_owned_by(struct, scope), do: ensure_owned_by!(struct, scope)

  defp visible_to_scope(query, scope) do
    where(query, [schema], schema.user_id == ^scope_user_id(scope) or schema.shared)
  end

  defp owned_by_scope(query, scope) do
    where(query, [schema], schema.user_id == ^scope_user_id(scope))
  end

  defp ensure_owned_by!(%schema{user_id: user_id} = struct, scope) when is_atom(schema) do
    if user_id == scope_user_id(scope) do
      struct
    else
      raise Ecto.NoResultsError, queryable: schema
    end
  end

  defp scope_user(%Scope{user: %User{} = user}), do: user

  defp scope_user_id(%Scope{user: %User{id: user_id}}), do: user_id
end
