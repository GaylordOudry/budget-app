defmodule BudgetAppWeb.ExpenseCategoryHTML do
  use BudgetAppWeb, :html

  embed_templates "expense_category_html/*"

  attr :form, :any, required: true
  attr :action, :string, required: true
  attr :return_to, :string, default: nil
  attr :current_user, :map, required: true

  def expense_category_form(assigns) do
    ~H"""
    <.form for={@form} id="expense-category-form" action={@action}>
      <div class="mb-4 rounded-2xl border border-base-300 bg-base-200/60 px-4 py-3 text-sm">
        <span class="text-base-content/60">Utilisateur actif :</span>
        <span class="font-medium text-base-content">{@current_user.name}</span>
      </div>

      <.input field={@form[:name]} type="text" label="Nom" />

      <footer class="mt-6 flex flex-wrap gap-3">
        <.button variant="primary">Enregistrer la catégorie</.button>
        <.button :if={@return_to} navigate={@return_to}>Annuler</.button>
      </footer>
    </.form>
    """
  end
end
