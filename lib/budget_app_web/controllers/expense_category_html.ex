defmodule BudgetAppWeb.ExpenseCategoryHTML do
  use BudgetAppWeb, :html

  embed_templates "expense_category_html/*"

  attr :form, :any, required: true
  attr :action, :string, required: true
  attr :return_to, :string, default: nil

  def expense_category_form(assigns) do
    ~H"""
    <.form for={@form} id="expense-category-form" action={@action}>
      <.input field={@form[:name]} type="text" label="Nom" />

      <footer class="mt-6 flex flex-wrap gap-3">
        <.button variant="primary">Enregistrer la catégorie</.button>
        <.button :if={@return_to} navigate={@return_to}>Annuler</.button>
      </footer>
    </.form>
    """
  end
end
