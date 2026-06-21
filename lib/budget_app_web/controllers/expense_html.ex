defmodule BudgetAppWeb.ExpenseHTML do
  use BudgetAppWeb, :html

  embed_templates "expense_html/*"

  attr :form, :any, required: true
  attr :action, :string, required: true
  attr :return_to, :string, default: nil
  attr :category_options, :list, required: true

  def expense_form(assigns) do
    ~H"""
    <.form for={@form} id="expense-form" action={@action}>
      <div class="grid gap-4 md:grid-cols-2">
        <.input field={@form[:date]} type="date" label="Date" />
        <.input field={@form[:amount]} type="number" step="0.01" label="Montant" />
        <.input field={@form[:currency]} type="text" maxlength="3" label="Devise" />
        <.input field={@form[:created_by]} type="text" label="Créé par" />
      </div>

      <.input
        field={@form[:category_id]}
        type="select"
        label="Catégorie"
        options={@category_options}
        prompt="Choisissez une catégorie"
      />

      <footer class="mt-6 flex flex-wrap gap-3">
        <.button variant="primary">Enregistrer la dépense</.button>
        <.button :if={@return_to} navigate={@return_to}>Annuler</.button>
      </footer>
    </.form>
    """
  end
end
