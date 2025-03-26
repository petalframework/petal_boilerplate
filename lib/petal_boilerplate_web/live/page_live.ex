defmodule PetalBoilerplateWeb.PageLive do
  use PetalBoilerplateWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       modal: false,
       slide_over: false,
       group_size: "md",
       pagination_page: 1,
       total_pages: 10,
       active_tab: :live,
       price_min: 50,
       price_max: 200,
       quantity_min: 1,
       quantity_max: 10
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
  def handle_event("range_updated", %{"id" => id, "min" => min, "max" => max}, socket)
      when id in ["price_range", "price_range_with_error"] do
    {:noreply, socket |> assign(:price_min, min) |> assign(:price_max, max)}
  end

  @impl true
  def handle_event("range_updated", %{"id" => id, "min" => min, "max" => max}, socket)
      when id in ["quantity_range", "quantity_range_with_error"] do
    {:noreply, socket |> assign(:quantity_min, min) |> assign(:quantity_max, max)}
  end

  @impl true
  def handle_event("change_size", %{"size" => size}, socket) do
    {:noreply, assign(socket, group_size: size)}
  end

  @impl true
  def handle_event("close_modal", _params, socket) do
    {:noreply, push_patch(socket, to: "/live")}
  end

  @impl true
  def handle_event("close_slide_over", _params, socket) do
    {:noreply, push_patch(socket, to: "/live")}
  end

  @impl true
  def handle_event("goto-page", %{"page" => page}, socket) do
    {:noreply, push_patch(socket, to: ~p"/live/pagination/#{page}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.container>
      <.h2 underline label="Forms V2" class="mb-12" />

      <% form =
        Phoenix.Component.to_form(
          %Ecto.Changeset{
            action: :update,
            data: %{name: ""},
            errors: [
              text_with_error: {"can't be blank", [validation: :required]},
              text_with_error: {"must be at least 2 characters", [validation: :minimum]},
              number_with_error: {"can't be blank", [validation: :required]},
              email_with_error: {"can't be blank", [validation: :required]},
              password_with_error: {"can't be blank", [validation: :required]},
              search_with_error: {"can't be blank", [validation: :required]},
              tel_with_error: {"can't be blank", [validation: :required]},
              url_with_error: {"can't be blank", [validation: :required]},
              time_with_error: {"can't be blank", [validation: :required]},
              date_with_error: {"can't be blank", [validation: :required]},
              week_with_error: {"can't be blank", [validation: :required]},
              month_with_error: {"can't be blank", [validation: :required]},
              datetime_local_with_error: {"can't be blank", [validation: :required]},
              color_with_error: {"can't be blank", [validation: :required]},
              file_with_error: {"can't be blank", [validation: :required]},
              range_with_error: {"can't be blank", [validation: :required]},
              textarea_with_error: {"can't be blank", [validation: :required]},
              select_with_error: {"can't be blank", [validation: :required]},
              switch_with_error: {"can't be blank", [validation: :required]},
              checkbox_with_error: {"can't be blank", [validation: :required]},
              checkbox_group_col_with_error: {"can't be blank", [validation: :required]},
              checkbox_group_row_with_error: {"can't be blank", [validation: :required]},
              radio_with_error: {"can't be blank", [validation: :required]},
              radio_card_with_error: {"can't be blank", [validation: :required]},
              radio_group_col_with_error: {"can't be blank", [validation: :required]},
              radio_group_row_with_error: {"can't be blank", [validation: :required]},
              range_dual_with_error: {"can't be blank", [validation: :required]},
              range_numeric_with_error: {"can't be blank", [validation: :required]},
              range_with_error: {"can't be blank", [validation: :required]}
            ]
          },
          as: :object
        ) %>
      <.form multipart for={form}>
        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field
              field={form[:text]}
              placeholder="Enter text"
              label="Clearable"
              type="text"
              clearable
            />
            <.field
              field={form[:text]}
              placeholder="This is just a placeholder"
              value="https://example.com/invite/your-invite-code"
              label="Copyable"
              copyable
            />
            <.field
              type="password"
              field={form[:password]}
              label="Viewable"
              placeholder="Placeholder"
              viewable
            />
            <.field type="text" field={form[:text]} placeholder="Placeholder" help_text="Help text" />
          </div>

          <div>
            <.field
              type="text"
              field={form[:text_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field type="email" field={form[:email]} placeholder="Placeholder" help_text="Help text" />
          </div>

          <div class="mb-6">
            <.field
              type="email"
              field={form[:email_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field
              type="number"
              field={form[:number]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>

          <div class="mb-6">
            <.field
              type="number"
              field={form[:number_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field
              type="password"
              field={form[:password]}
              placeholder="Placeholder"
              help_text="Help text"
              viewable
            />
          </div>

          <div class="mb-6">
            <.field
              type="password"
              field={form[:password_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field
              type="search"
              field={form[:search]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>

          <div class="mb-6">
            <.field
              type="search"
              field={form[:search_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field type="tel" field={form[:tel]} placeholder="Placeholder" help_text="Help text" />
          </div>

          <div class="mb-6">
            <.field
              type="tel"
              field={form[:tel_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field type="url" field={form[:url]} placeholder="Placeholder" help_text="Help text" />
          </div>

          <div class="mb-6">
            <.field
              type="url"
              field={form[:url_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field type="time" field={form[:time]} placeholder="Placeholder" help_text="Help text" />
          </div>

          <div class="mb-6">
            <.field
              type="time"
              field={form[:time_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field type="week" field={form[:week]} placeholder="Placeholder" help_text="Help text" />
          </div>

          <div class="mb-6">
            <.field
              type="week"
              field={form[:week_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field type="month" field={form[:month]} placeholder="Placeholder" help_text="Help text" />
          </div>

          <div class="mb-6">
            <.field
              type="month"
              field={form[:month_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field type="date" field={form[:date]} placeholder="Placeholder" help_text="Help text" />
          </div>

          <div class="mb-6">
            <.field
              type="date"
              field={form[:date_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field
              type="datetime-local"
              field={form[:datetime_local]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>

          <div class="mb-6">
            <.field
              type="datetime-local"
              field={form[:datetime_local_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field type="color" field={form[:color]} placeholder="Placeholder" help_text="Help text" />
          </div>

          <div class="mb-6">
            <.field
              type="color"
              field={form[:color_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field type="file" field={form[:file]} placeholder="Placeholder" help_text="Help text" />
          </div>

          <div class="mb-6">
            <.field
              type="file"
              field={form[:file_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field
              type="range"
              class="pc-range-input"
              field={form[:range]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>

          <div class="mb-6">
            <.field
              type="range"
              field={form[:range_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>
        
    <!-- Dual Range Slider Examples -->
        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field
              type="range-dual"
              id="price_range"
              label="Select Price Range (Dual Slider)"
              range_min={0}
              range_max={500}
              range_min_label="$0"
              range_max_label="$500"
              step={10}
              min_field={%{name: "min_price", value: @price_min}}
              max_field={%{name: "max_price", value: @price_max}}
              field={form[:range_dual]}
              help_text="Help text"
            />
          </div>
          <div class="mb-6">
            <.field
              type="range-dual"
              id="price_range_with_error"
              label="Select Price Range (Dual Slider with Error)"
              range_min={0}
              range_max={500}
              range_min_label="$0"
              range_max_label="$500"
              step={10}
              min_field={%{name: "min_price", value: @price_min}}
              max_field={%{name: "max_price", value: @price_max}}
              field={form[:range_dual_with_error]}
              help_text="Help text"
            />
          </div>
        </div>
        
    <!-- Numeric Range Examples -->
        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field
              type="range-numeric"
              id="quantity_range"
              label="Select Quantity Range (Numeric Inputs)"
              range_min={1}
              range_max={100}
              step={1}
              min_field={%{name: "min_quantity", value: @quantity_min}}
              max_field={%{name: "max_quantity", value: @quantity_max}}
              field={form[:range_numeric]}
              help_text="Help text"
            />
          </div>
          <div class="mb-6">
            <.field
              type="range-numeric"
              id="quantity_range_with_error"
              label="Select Quantity Range (Numeric Inputs with Error)"
              range_min={1}
              range_max={100}
              step={1}
              min_field={%{name: "min_quantity", value: @quantity_min}}
              max_field={%{name: "max_quantity", value: @quantity_max}}
              field={form[:range_numeric_with_error]}
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field
              type="textarea"
              field={form[:textarea]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>

          <div class="mb-6">
            <.field
              type="textarea"
              field={form[:textarea_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 mb-6 md:grid-cols-2">
          <div>
            <.field
              type="select"
              options={[Admin: "admin", User: "user"]}
              field={form[:select]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>

          <div class="mb-6">
            <.field
              type="select"
              options={[Admin: "admin", User: "user"]}
              field={form[:select_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 mb-6 md:grid-cols-2">
          <div>
            <.field type="switch" field={form[:xs]} placeholder="Placeholder" help_text="Help text" />
          </div>

          <div class="mb-6">
            <.field
              type="switch"
              size="xs"
              field={form[:switch_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
          <div>
            <.field
              type="switch"
              field={form[:sm]}
              size="sm"
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>

          <div class="mb-6">
            <.field
              type="switch"
              size="sm"
              field={form[:switch_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
          <div>
            <.field
              type="switch"
              field={form[:md]}
              size="md"
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>

          <div class="mb-6">
            <.field
              type="switch"
              size="md"
              field={form[:switch_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
          <div>
            <.field
              type="switch"
              field={form[:lg]}
              size="lg"
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>

          <div class="mb-6">
            <.field
              type="switch"
              size="lg"
              field={form[:switch_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
          <div>
            <.field
              type="switch"
              field={form[:xl]}
              size="xl"
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>

          <div class="mb-6">
            <.field
              type="switch"
              size="xl"
              field={form[:switch_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field
              type="checkbox"
              field={form[:checkbox]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>

          <div class="mb-6">
            <.field
              type="checkbox"
              field={form[:checkbox_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 mb-6 md:grid-cols-2">
          <div>
            <.field
              type="checkbox-group"
              group_layout="col"
              options={[Admin: "admin", User: "user"]}
              field={form[:checkbox_group_col]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>

          <div class="mb-6">
            <.field
              type="checkbox-group"
              group_layout="col"
              options={[Admin: "admin", User: "user"]}
              field={form[:checkbox_group_col_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 mb-6 md:grid-cols-2">
          <div>
            <.field
              type="checkbox-group"
              layout="row"
              options={[Admin: "admin", User: "user"]}
              field={form[:checkbox_group_row]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>

          <div class="mb-6">
            <.field
              type="checkbox-group"
              layout="row"
              options={[Admin: "admin", User: "user"]}
              field={form[:checkbox_group_row_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 mb-6 md:grid-cols-2">
          <div>
            <.field
              type="radio-group"
              group_layout="col"
              options={[Admin: "admin", User: "user"]}
              field={form[:radio_group_col]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>

          <div class="mb-6">
            <.field
              type="radio-group"
              group_layout="col"
              options={[Admin: "admin", User: "user"]}
              field={form[:radio_group_col_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 mb-6 md:grid-cols-2">
          <div>
            <.field
              type="radio-group"
              group_layout="row"
              options={[Admin: "admin", User: "user"]}
              field={form[:radio_group_row]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>

          <div class="mb-6">
            <.field
              type="radio-group"
              group_layout="row"
              options={[Admin: "admin", User: "user"]}
              field={form[:radio_group_row_with_error]}
              placeholder="Placeholder"
              help_text="Help text"
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field
              type="radio-card"
              field={form[:radio_card]}
              label="Radio card row"
              options={[
                %{label: "8-core CPU", value: "high", description: "32 GB RAM"},
                %{label: "6-core CPU", value: "mid", description: "24 GB RAM"},
                %{
                  label: "4-core CPU",
                  value: "low",
                  description: "16 GB RAM",
                  disabled: true
                }
              ]}
              size="sm"
              variant="outline"
              help_text="Choose the plan that best suits your needs."
              required
            />
          </div>

          <div>
            <.field
              type="radio-card"
              field={form[:radio_card_with_error]}
              label="Radio card row (with error)"
              options={[
                %{label: "8-core CPU", value: "high", description: "32 GB RAM"},
                %{label: "6-core CPU", value: "mid", description: "24 GB RAM"},
                %{
                  label: "4-core CPU",
                  value: "low",
                  description: "16 GB RAM",
                  disabled: true
                }
              ]}
              size="sm"
              variant="outline"
              help_text="This field is required."
              required
            />
          </div>
        </div>

        <div class="grid grid-cols-1 gap-4 md:grid-cols-2">
          <div>
            <.field
              type="radio-card"
              field={form[:radio_card]}
              label="Radio card col"
              options={[
                %{label: "8-core CPU", value: "high", description: "32 GB RAM"},
                %{label: "6-core CPU", value: "mid", description: "24 GB RAM"},
                %{
                  label: "4-core CPU",
                  value: "low",
                  description: "16 GB RAM",
                  disabled: true
                }
              ]}
              size="sm"
              group_layout="col"
              variant="outline"
              help_text="Choose the plan that best suits your needs."
              required
            />
          </div>

          <div>
            <.field
              type="radio-card"
              field={form[:radio_card_with_error]}
              label="Radio card col (with error)"
              options={[
                %{label: "8-core CPU", value: "high", description: "32 GB RAM"},
                %{label: "6-core CPU", value: "mid", description: "24 GB RAM"},
                %{
                  label: "4-core CPU",
                  value: "low",
                  description: "16 GB RAM",
                  disabled: true
                }
              ]}
              size="sm"
              group_layout="col"
              variant="outline"
              help_text="This field is required."
              required
            />
          </div>
        </div>
      </.form>
    </.container>

    <.container class="mt-10 mb-32">
      <.accordion variant="ghost" open_index={1}>
        <:item heading="Why don't some couples go to the gym?">
          <.p class="text-base leading-7 text-gray-600 dark:text-gray-400">
            Because some relationships don't work out.
            They start strong, but eventually, one partner's enthusiasm just fizzles out. It's like buying a treadmill and using it as a fancy clothes hanger. Love needs cardio too, but not everyone's ready to break a sweat!
          </.p>
        </:item>
        <:item heading="Why did the bicycle fall over?">
          <.p class="text-base leading-7 text-gray-600 dark:text-gray-400">
            Because it was two-tired.
            After all those uphill battles and no gears to change, it just couldn't keep it together anymore. I mean, who wouldn't wobble under that pressure? Sometimes even a bike needs a break… or maybe just a kickstand!
          </.p>
        </:item>
        <:item heading="Why don't scientists trust atoms?">
          <.p class="text-base leading-7 text-gray-600 dark:text-gray-400">
            Because they make up everything.
            Seriously, they can't help but fabricate all the stuff around us. They're like the ultimate storytellers, weaving tales of reality while we're just trying to live in it. They'll have you believing in the periodic table like it's some kind of life hack.
          </.p>
        </:item>
        <:item heading="Why did the tomato blush?">
          <.p class="text-base leading-7 text-gray-600 dark:text-gray-400">
            Because it saw the salad dressing.
            It's hard to stay cool when everyone's watching you mix it up with those fresh greens. The poor tomato wasn't ready for that kind of exposure. A little too much vinaigrette and, well, things get steamy in the kitchen real fast!
          </.p>
        </:item>
        <:item heading="What do you call fake spaghetti?">
          <.p class="text-base leading-7 text-gray-600 dark:text-gray-400">
            An impasta.
            It's always trying to blend in with the real deal, but you can tell something's off. Too much starch, maybe? It tries to twirl around your fork, but you know it's just not the same. Fake pasta: the ultimate culinary con artist!
          </.p>
        </:item>
      </.accordion>
      <.accordion open_index={1}>
        <:item heading="Why did the tomato blush?">
          <.p class="text-base leading-7 text-gray-600 dark:text-gray-400">
            I don't know, but the flag is a big plus. Lorem ipsum dolor sit amet consectetur adipisicing elit.
          </.p>
        </:item>
        <:item heading="Another question">
          <.p class="text-base leading-7 text-gray-600 dark:text-gray-400">
            Another answer...
          </.p>
        </:item>
        <:item heading="Another question">
          <.p class="text-base leading-7 text-gray-600 dark:text-gray-400">
            Another answer...
          </.p>
        </:item>
        <:item heading="Another question">
          <.p class="text-base leading-7 text-gray-600 dark:text-gray-400">
            Another answer...
          </.p>
        </:item>
      </.accordion>
      <.h2 underline class="mt-10" label="Dropdowns" />
      <.h3 label="" />
      <.dropdown label="Dropdown" js_lib="live_view_js" placement="right">
        <.dropdown_menu_item type="button">
          <.icon name="hero-home" class="w-5 h-5 text-gray-500 dark:text-gray-300" />
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

      <.h2 underline class="mt-10" label="Button Group" />

      <.button_group aria_label="Size options" size={@group_size}>
        <:button phx-click="change_size" phx-value-size="xs">XS</:button>
        <:button phx-click="change_size" phx-value-size="sm">SM</:button>
        <:button phx-click="change_size" phx-value-size="md">MD</:button>
        <:button phx-click="change_size" phx-value-size="lg">LG</:button>
        <:button phx-click="change_size" phx-value-size="xl">XL</:button>
      </.button_group>

      <%= if @modal do %>
        <.modal max_width={@modal} title="Modal">
          <div class="gap-5 text-sm">
            <.form_label label="Add some text here." />
            <div class="flex justify-end">
              <.button label="close" phx-click={JS.exec("data-cancel", to: "#modal")} />
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
        <.slide_over origin={@slide_over} title="SlideOver" max_width="xl">
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
        total_pages={@total_pages}
      />
    </.container>
    """
  end

  @impl true
  def handle_event("change_size", %{"size" => size}, socket) do
    {:noreply, assign(socket, group_size: size)}
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, push_patch(socket, to: "/live")}
  end

  def handle_event("close_slide_over", _, socket) do
    {:noreply, push_patch(socket, to: "/live")}
  end

  @impl true
  def handle_event("goto-page", %{"page" => page}, socket) do
    {:noreply, push_patch(socket, to: ~p"/live/pagination/#{page}")}
  end
end
