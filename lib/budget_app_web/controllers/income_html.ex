defmodule BudgetAppWeb.IncomeHTML do
  use BudgetAppWeb, :html

  embed_templates "income_html/*"

  attr :form, :any, required: true
  attr :action, :string, required: true
  attr :return_to, :string, default: nil
  attr :current_user, :map, required: true

  def income_form(assigns) do
    ~H"""
    <.form for={@form} id="income-form" action={@action}>
      <div class="mb-4 rounded-2xl border border-base-300 bg-base-200/60 px-4 py-3 text-sm">
        <span class="text-base-content/60">Utilisateur actif :</span>
        <span class="font-medium text-base-content">{@current_user.name}</span>
      </div>

      <div class="grid gap-4 md:grid-cols-2">
        <.input field={@form[:date]} type="date" label="Date" />
        <.input field={@form[:amount]} type="number" step="0.01" label="Montant" />
        <.input field={@form[:currency]} type="text" maxlength="3" label="Devise" />
      </div>

      <footer class="mt-6 flex flex-wrap gap-3">
        <.button variant="primary">Enregistrer le revenu</.button>
        <.button :if={@return_to} navigate={@return_to}>Annuler</.button>
      </footer>
    </.form>
    """
  end
end
