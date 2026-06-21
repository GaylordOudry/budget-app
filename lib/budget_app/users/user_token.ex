defmodule BudgetApp.Users.UserToken do
  use Ecto.Schema
  import Ecto.Query

  alias BudgetApp.Users.UserToken

  # 32 bytes gives 256 bits of entropy for session tokens.
  @rand_size 32
  @session_validity_in_days 14

  schema "users_tokens" do
    field :token, :binary
    field :context, :string
    field :authenticated_at, :utc_datetime
    belongs_to :user, BudgetApp.Users.User

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def build_session_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    authenticated_at = user.authenticated_at || DateTime.utc_now(:second)

    {token,
     %UserToken{
       token: token,
       context: "session",
       authenticated_at: authenticated_at,
       user_id: user.id
     }}
  end

  def verify_session_token_query(token) do
    query =
      from user_token in by_token_and_context_query(token, "session"),
        join: user in assoc(user_token, :user),
        where: user_token.inserted_at > ago(@session_validity_in_days, "day"),
        select: {%{user | authenticated_at: user_token.authenticated_at}, user_token.inserted_at}

    {:ok, query}
  end

  defp by_token_and_context_query(token, context) do
    from UserToken, where: [token: ^token, context: ^context]
  end
end
