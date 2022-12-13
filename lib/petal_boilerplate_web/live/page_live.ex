defmodule PetalBoilerplateWeb.PageLive do
  use PetalBoilerplateWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       modal: false,
       slide_over: false,
       pagination_page: 1,
       active_tab: :live
     )}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    case socket.assigns.live_action do
      :index ->
        {:noreply, assign(socket, modal: false, slide_over: false)}

      :modal ->
        {:noreply, assign(socket, modal: params["size"])}

      :slide_over ->
        {:noreply, assign(socket, slide_over: params["origin"])}

      :pagination ->
        {:noreply, assign(socket, pagination_page: String.to_integer(params["page"]))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.container class="mt-10 mb-32">
      <.h2 underline class="mt-10" label="Dropdowns" />
      <.h3 label="" />
      <.dropdown label="Dropdown" js_lib="live_view_js">
        <.dropdown_menu_item type="button">
          <HeroiconsV1.Outline.home class="w-5 h-5 text-gray-500 dark:text-gray-300" />
          Button item with icon
        </.dropdown_menu_item>
        <.dropdown_menu_item type="a" to="/" label="a item" />
        <.dropdown_menu_item type="live_patch" to="/" label="Live Patch item" />
        <.dropdown_menu_item type="live_redirect" to="/" label="Live Redirect item" />
      </.dropdown>

      <.h2 underline class="mt-10" label="Modal" />

      <.button label="sm" link_type="live_patch" to={~p"/live/modal/sm"} />
      <.button label="md" link_type="live_patch" to={~p"/live/modal/md"} />
      <.button label="lg" link_type="live_patch" to={~p"/live/modal/lg"} />
      <.button label="xl" link_type="live_patch" to={~p"/live/modal/xl"} />
      <.button label="2xl" link_type="live_patch" to={~p"/live/modal/2xl"} />
      <.button label="full" link_type="live_patch" to={~p"/live/modal/full"} />

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

      <.h2 underline class="mt-10" label="SlideOver" />

      <.button label="left" link_type="live_patch" to={~p"/live/slide_over/left"} />
      <.button label="top" link_type="live_patch" to={~p"/live/slide_over/top"} />
      <.button label="right" link_type="live_patch" to={~p"/live/slide_over/right"} />
      <.button label="bottom" link_type="live_patch" to={~p"/live/slide_over/bottom"} />

      <%= if @slide_over do %>
        <.slide_over origin={@slide_over} title="SlideOver">
          <div class="gap-5 text-sm">
            <.form_label label="Add some text here." />
            <div class="flex justify-end">
              <.button
                label="close"
                phx-click={PetalComponents.SlideOver.hide_slide_over(@slide_over)}
              />
            </div>
          </div>
        </.slide_over>
      <% end %>

      <.h2 underline class="mt-10" label="Interactive Pagination" />
      <.pagination
        link_type="live_patch"
        path="/live/pagination/:page"
        current_page={@pagination_page}
        total_pages={10}
      />

      <.h2 underline class="mt-10" label="Accordion" />
      <.accordion js_lib="live_view_js">
        <:item heading="Accordion">
          <.p>
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam quis. Ut enim ad minim veniam quis. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          </.p>
        </:item>
        <:item heading="Accordion 2">
          <.p>
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam quis. Ut enim ad minim veniam quis. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          </.p>
        </:item>
        <:item heading="Accordion 3">
          <.p>
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam quis. Ut enim ad minim veniam quis. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
          </.p>
        </:item>
      </.accordion>
    </.container>
    """
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: "/live")}
  end

  def handle_event("close_slide_over", _, socket) do
    {:noreply, push_patch(socket, to: "/live")}
  end
end
