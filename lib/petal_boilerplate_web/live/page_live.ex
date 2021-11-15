defmodule PetalBoilerplateWeb.PageLive do
  use PetalBoilerplateWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.container class="mt-10">
      <.link class="underline" to="/">Back</.link>
      <.h2 underline class="mt-3" label="Dropdowns" />
      <.h3 label="" />
      <.dropdown label="Live View JS Dropdown" js_lib="live_view_js">
        <.dropdown_menu_item type="button">
          <Heroicons.Outline.home class="w-5 h-5 text-gray-500" />
          Button item with icon
        </.dropdown_menu_item>
        <.dropdown_menu_item type="a" href="/" label="a item" />
        <.dropdown_menu_item type="live_patch" href="/" label="Live Patch item" />
        <.dropdown_menu_item type="live_redirect" href="/" label="Live Redirect item" />
      </.dropdown>
    </.container>
    """
  end
end
