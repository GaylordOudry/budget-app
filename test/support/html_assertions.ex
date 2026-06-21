defmodule BudgetAppWeb.HTMLAssertions do
  import ExUnit.Assertions

  def assert_navigation_menu(html) do
    document = LazyHTML.from_fragment(html)

    assert [_ | _] = LazyHTML.filter(document, "#app-navigation a[href='/expenses']")
    assert [_ | _] = LazyHTML.filter(document, "#app-navigation a[href='/incomes']")
    assert [_ | _] = LazyHTML.filter(document, "#app-navigation a[href='/categories']")
  end
end