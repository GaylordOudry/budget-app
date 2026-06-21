defmodule BudgetAppWeb.IncomeHTML do
  use BudgetAppWeb, :html

  embed_templates "income_html/*"

  attr :form, :any, required: true
  attr :action, :string, required: true
  attr :return_to, :string, default: nil

  def income_form(assigns) do
    ~H"""
    <.form for={@form} id="income-form" action={@action}>
      <div class="grid gap-4 md:grid-cols-2">
        <.input field={@form[:date]} type="date" label="Date" />
        <.input field={@form[:amount]} type="number" step="0.01" label="Amount" />
        <.input field={@form[:currency]} type="text" maxlength="3" label="Currency" />
        <.input field={@form[:created_by]} type="text" label="Created by" />
      </div>

      <footer class="mt-6 flex flex-wrap gap-3">
        <.button variant="primary">Save income</.button>
        <.button :if={@return_to} navigate={@return_to}>Cancel</.button>
      </footer>
    </.form>
    """
  end
end
