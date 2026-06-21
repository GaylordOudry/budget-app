defmodule BudgetAppWeb.Router do
  use BudgetAppWeb, :router

  import BudgetAppWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {BudgetAppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_scope_for_user
  end

  pipeline :require_authenticated_user do
    plug :require_authenticated_user
  end

  pipeline :redirect_if_user_is_authenticated do
    plug :redirect_if_user_is_authenticated
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BudgetAppWeb do
    pipe_through :browser

    get "/", UserController, :home
    get "/users", UserController, :index
    post "/users/log-in", UserController, :log_in
    delete "/users/log-out", UserController, :log_out
  end

  scope "/", BudgetAppWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    post "/users", UserController, :create
  end

  scope "/", BudgetAppWeb do
    pipe_through [:browser, :require_authenticated_user]

    resources "/categories", ExpenseCategoryController
    resources "/expenses", ExpenseController
    resources "/incomes", IncomeController
  end

  # Other scopes may use custom stacks.
  # scope "/api", BudgetAppWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:budget_app, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BudgetAppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
