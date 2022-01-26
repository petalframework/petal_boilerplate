defmodule PetalBoilerplateWeb.PageLive do
  use PetalBoilerplateWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :modal, false)}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    case socket.assigns.live_action do
      :index ->
        {:noreply, assign(socket, modal: false)}
      :modal ->
        {:noreply, assign(socket, modal: params["size"])}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-screen overflow-auto dark:bg-gray-900">
      <nav class="sticky top-0 flex items-center justify-end w-full h-12 bg-white dark:bg-gray-900">
        <div class="flex justify-end pr-3">
          <div class="bg-pink-400 hover:bg-pink-500/90 theme-switch-wrapper dark:bg-gray-600 dark:hover:bg-gray-500/80">
            <input type="checkbox" class="theme-switch" id="theme-switch">
            <div class="switch-ui">
              <svg class="moon" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg"><path d="M8 16a7.947 7.947 0 003.5-.815C8.838 13.886 7 11.161 7 8S8.838 2.114 11.5.815A7.947 7.947 0 008 0a8 8 0 000 16zM14 3a2 2 0 01-2 2 2 2 0 012 2 2 2 0 012-2 2 2 0 01-2-2z" /><path d="M10 6a2 2 0 01-2 2 2 2 0 012 2 2 2 0 012-2 2 2 0 01-2-2zM13 13a2 2 0 012-2 2 2 0 01-2-2 2 2 0 01-2 2 2 2 0 012 2z" /></svg>
              <svg class="sun" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg"><circle cx="8.5" cy="7.5" r="4.5" /><path d="M8 0h1v2H8zM8 13h1v2H8zM14 7h2v1h-2zM1 7h2v1H1zM12.035 11.743l.707-.707 1.414 1.414-.707.707zM2.843 2.55l.707-.707 1.415 1.414-.707.707zM2.843 12.45l1.414-1.415.707.707-1.414 1.415zM12.035 3.257l1.414-1.414.708.707-1.415 1.415z" /></svg>
            </div>
          </div>
        </div>
      </nav>
      <.container class="mt-10">
        <.link class="underline dark:text-gray-400" to="/">Back</.link>
        <.h1 class="mt-5" label="Petal Live View JS Components" />
        <.h2 underline class="mt-10" label="Dropdowns" />
        <.h3 label="" />
        <.dropdown label="Dropdown" js_lib="live_view_js">
          <.dropdown_menu_item type="button">
            <Heroicons.Outline.home class="w-5 h-5 text-gray-500 dark:text-gray-300" />
            Button item with icon
          </.dropdown_menu_item>
          <.dropdown_menu_item type="a" href="/" label="a item" />
          <.dropdown_menu_item type="live_patch" href="/" label="Live Patch item" />
          <.dropdown_menu_item type="live_redirect" href="/" label="Live Redirect item" />
        </.dropdown>
      </.container>

      <.container class="mt-10">
        <.h2 underline class="mt-3" label="Modal" />

        <.button label="sm" link_type="live_patch" to={Routes.page_path(@socket, :modal, "sm")} />
        <.button label="md" link_type="live_patch" to={Routes.page_path(@socket, :modal, "md")} />
        <.button label="lg" link_type="live_patch" to={Routes.page_path(@socket, :modal, "lg")} />
        <.button label="xl" link_type="live_patch" to={Routes.page_path(@socket, :modal, "xl")} />
        <.button label="2xl" link_type="live_patch" to={Routes.page_path(@socket, :modal, "2xl")} />
        <.button label="full" link_type="live_patch" to={Routes.page_path(@socket, :modal, "full")} />

        <%= if @modal do %>
          <.modal max_width={@modal} title="Modal">
            <div class="gap-5 text-sm">
              <.form_label label="Add some text here." />
              <div class="flex justify-end">
                <.button label="close" phx-click={PetalComponents.Modal.hide_modal()} />
              </div>
            </div>
          </.modal>
        <% end %>

      </.container>
    </div>
    """
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: "/live")}
  end
end
