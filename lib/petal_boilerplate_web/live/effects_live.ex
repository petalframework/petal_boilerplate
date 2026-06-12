defmodule PetalBoilerplateWeb.EffectsLive do
  @moduledoc """
  Showcase for the navigation menu and the animated "special effects"
  components: border beam, meteors, text animations, number ticker,
  spotlight cards and confetti.
  """
  use PetalBoilerplateWeb, :live_view

  alias Phoenix.LiveView.JS

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, active_tab: :effects, stars: 5200)}
  end

  @impl true
  def handle_event("randomize_stars", _, socket) do
    {:noreply, assign(socket, :stars, Enum.random(3_000..9_999))}
  end

  def handle_event("celebrate", _, socket) do
    {:noreply, push_event(socket, "pc-confetti", %{})}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.container class="py-10 space-y-14">
      <section>
        <.h2 underline class="mb-6" label="Navigation Menu" />
        <.p class="mb-4 text-sm text-gray-500 dark:text-gray-400">
          A flyout menu for navigation that holds more than a dropdown can. Click a trigger to open
          its panel — Escape or clicking away closes it.
        </.p>
        <div class="rounded-xl border border-gray-200 bg-white px-4 py-2 dark:border-gray-700 dark:bg-gray-900">
          <.navigation_menu id="demo-nav">
            <:item label="Products" width="md">
              <.navigation_menu_link
                to="#"
                icon="hero-chart-bar"
                title="Analytics"
                description="Get a better understanding of your traffic"
              />
              <.navigation_menu_link
                to="#"
                icon="hero-cursor-arrow-rays"
                title="Engagement"
                description="Speak directly to your customers"
              />
              <.navigation_menu_link
                to="#"
                icon="hero-shield-check"
                title="Security"
                description="Your customers' data is safe and secure"
              />
              <.navigation_menu_footer>
                <.navigation_menu_footer_link to="#" icon="hero-play-circle" label="Watch demo" />
                <.navigation_menu_footer_link to="#" icon="hero-phone" label="Contact sales" />
              </.navigation_menu_footer>
            </:item>
            <:item label="Solutions" width="xl">
              <div class="grid grid-cols-2 gap-1">
                <.navigation_menu_link
                  to="#"
                  icon="hero-building-storefront"
                  title="E-commerce"
                  description="Sell products online"
                />
                <.navigation_menu_link
                  to="#"
                  icon="hero-users"
                  title="SaaS"
                  description="Multi-tenant apps"
                />
                <.navigation_menu_link
                  to="#"
                  icon="hero-newspaper"
                  title="Content"
                  description="Blogs and publications"
                />
                <.navigation_menu_link
                  to="#"
                  icon="hero-chart-pie"
                  title="Dashboards"
                  description="Internal tools and admin"
                />
              </div>
            </:item>
            <:item label="Pricing" to="#" />
            <:item label="Docs" to="#" current />
          </.navigation_menu>
        </div>
      </section>

      <section>
        <.h2 underline class="mb-6" label="Text Animations" />
        <div class="space-y-8">
          <div>
            <.h4 class="mb-2">Gradient Text</.h4>
            <.gradient_text class="text-4xl font-bold">Build beautiful Phoenix apps</.gradient_text>
          </div>
          <div>
            <.h4 class="mb-2">Shimmer Text</.h4>
            <.shimmer_text class="text-lg font-medium">
              ✨ Introducing Petal Components
            </.shimmer_text>
          </div>
          <div>
            <.h4 class="mb-2">Word Rotate</.h4>
            <span class="text-3xl font-bold text-gray-900 dark:text-white">
              Petal makes your app
              <.word_rotate
                id="effects-word-rotate"
                words={["beautiful.", "fast.", "accessible.", "consistent."]}
                class="text-primary-600 dark:text-primary-400"
              />
            </span>
          </div>
          <div>
            <.h4 class="mb-2">Typing Effect</.h4>
            <.typing_effect
              id="effects-typing"
              text="mix igniter.install petal_components"
              loop
              class="font-mono text-lg text-gray-900 dark:text-white"
            />
          </div>
        </div>
      </section>

      <section>
        <.h2 underline class="mb-6" label="Number Ticker" />
        <div class="flex flex-wrap items-end gap-8">
          <div>
            <.number_ticker
              id="effects-ticker-stars"
              value={@stars}
              class="text-4xl font-bold text-gray-900 dark:text-white"
            />
            <.p class="text-sm text-gray-500">GitHub stars</.p>
          </div>
          <div>
            <.number_ticker
              id="effects-ticker-mrr"
              value={12480}
              prefix="$"
              class="text-4xl font-bold text-gray-900 dark:text-white"
            />
            <.p class="text-sm text-gray-500">MRR</.p>
          </div>
          <div>
            <.number_ticker
              id="effects-ticker-uptime"
              value={99.98}
              decimal_places={2}
              suffix="%"
              class="text-4xl font-bold text-gray-900 dark:text-white"
            />
            <.p class="text-sm text-gray-500">Uptime</.p>
          </div>
          <.button size="sm" variant="outline" label="Update value" phx-click="randomize_stars" />
        </div>
        <.p class="mt-2 text-sm text-gray-500">
          Counts up when scrolled into view. Updating the assign animates from the old value to the new one.
        </.p>
      </section>

      <section>
        <.h2 underline class="mb-6" label="Border Beam" />
        <div class="grid max-w-3xl gap-6 md:grid-cols-2">
          <.border_beam>
            <div class="p-8">
              <.h4>Default beam</.h4>
              <.p class="text-sm text-gray-500">An animated beam travels along the border.</.p>
            </div>
          </.border_beam>
          <.border_beam color_from="#38bdf8" color_to="#818cf8" duration="5s">
            <div class="p-8">
              <.h4>Custom colors</.h4>
              <.p class="text-sm text-gray-500">color_from, color_to, duration, size.</.p>
            </div>
          </.border_beam>
        </div>
      </section>

      <section>
        <.h2 underline class="mb-6" label="Meteors" />
        <div class="relative max-w-3xl overflow-hidden rounded-xl bg-gray-950 px-8 py-16">
          <.meteors count={25} />
          <div class="relative text-center">
            <.h3 class="text-white">Ship faster with Petal</.h3>
            <.p class="text-gray-400">Pure CSS — meteor positions are generated server-side.</.p>
          </div>
        </div>
      </section>

      <section>
        <.h2 underline class="mb-6" label="Spotlight Cards" />
        <div class="grid max-w-4xl gap-4 md:grid-cols-3">
          <.spotlight_card id="spotlight-1">
            <div class="p-6">
              <.icon name="hero-bolt" class="mb-3 h-6 w-6 text-primary-600 dark:text-primary-400" />
              <.h5>Fast by default</.h5>
              <.p class="text-sm text-gray-500">Server-rendered, minimal JS.</.p>
            </div>
          </.spotlight_card>
          <.spotlight_card id="spotlight-2">
            <div class="p-6">
              <.icon name="hero-swatch" class="mb-3 h-6 w-6 text-primary-600 dark:text-primary-400" />
              <.h5>Themeable</.h5>
              <.p class="text-sm text-gray-500">Tailwind v4 with pc-* overrides.</.p>
            </div>
          </.spotlight_card>
          <.spotlight_card id="spotlight-3" spotlight_color="rgb(56 189 248 / 0.25)">
            <div class="p-6">
              <.icon
                name="hero-cursor-arrow-ripple"
                class="mb-3 h-6 w-6 text-primary-600 dark:text-primary-400"
              />
              <.h5>Custom glow</.h5>
              <.p class="text-sm text-gray-500">Move your cursor over this card.</.p>
            </div>
          </.spotlight_card>
        </div>
      </section>

      <section class="pb-10">
        <.h2 underline class="mb-6" label="Confetti" />
        <.confetti id="effects-confetti" />
        <div class="flex flex-wrap gap-3">
          <.button label="Server burst 🎉" phx-click="celebrate" />
          <.button
            variant="outline"
            label="Client burst (no round trip)"
            phx-click={JS.dispatch("pc:confetti", to: "#effects-confetti")}
          />
        </div>
        <.p class="mt-2 text-sm text-gray-500">
          Fire from the server with <code>push_event(socket, "pc-confetti", %{})</code>
          or from the client with <code>JS.dispatch("pc:confetti")</code>.
        </.p>
      </section>
    </.container>
    """
  end
end
