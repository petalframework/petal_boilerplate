defmodule PetalBoilerplateWeb.PageLive do
  use PetalBoilerplateWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign(socket, [
      modal: false,
      pagination_page: 1,
      color_scheme: session["color_scheme"]
    ])}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    case socket.assigns.live_action do
      :index ->
        {:noreply, assign(socket, modal: false)}
      :modal ->
        {:noreply, assign(socket, modal: params["size"])}
      :pagination ->
        {:noreply, assign(socket, pagination_page: String.to_integer(params["page"]))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-screen overflow-auto dark:bg-gray-900">
      <nav class="sticky top-0 flex items-center justify-end w-full h-12 bg-white dark:bg-gray-900">
        <div class="flex justify-end pt-3 pr-3">
          <.color_scheme_switch color_scheme={@color_scheme} />
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

        <.h2 underline class="mt-10" label="Interactive Pagination" />
        <.pagination
          link_type="live_patch"
          path="/live/pagination/:page"
          current_page={@pagination_page} total_pages={10}
        />

      </.container>
    </div>
    """
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: "/live")}
  end
end
