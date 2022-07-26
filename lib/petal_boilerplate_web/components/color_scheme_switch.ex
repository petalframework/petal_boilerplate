defmodule PetalBoilerplateWeb.Components.ColorSchemeSwitch do
  use Phoenix.Component

  @doc """
  A button that switches between light and dark modes.
  Pairs with css-theme-switch.js
  """
  def color_scheme_switch(assigns) do
    ~H"""
    <button
      phx-hook="ColorSchemeHook"
      type="button"
      id={Ecto.UUID.generate()}
      class="color-scheme text-gray-500 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-700 focus:outline-none focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-700 rounded-lg text-sm p-2.5"
    >
      <svg
        class="hidden w-5 h-5 color-scheme-dark-icon"
        fill="currentColor"
        viewBox="0 0 20 20"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z"></path>
      </svg>
      <svg
        class="hidden w-5 h-5 color-scheme-light-icon"
        fill="currentColor"
        viewBox="0 0 20 20"
        xmlns="http://www.w3.org/2000/svg"
      >
        <path
          d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z"
          fill-rule="evenodd"
          clip-rule="evenodd"
        >
        </path>
      </svg>
    </button>
    """
  end

  # The script below is for switching dark/light color schemes.
  # This needs to be inlined in the <head> because it will set a class on the document, which affects all "dark" prefixed classed (eg. dark:text-white). If you do this in the body or a separate javascript file then when in dark mode, the page will flash in light mode first before switching to dark mode.
  # Used by `color-scheme-hook.js`.
  def color_scheme_switch_js(assigns) do
    ~H"""
    <script>
      window.applyScheme = function(scheme) {
        if (scheme === "light") {
          document.documentElement.classList.remove('dark')
          document
            .querySelectorAll(".color-scheme-dark-icon")
            .forEach((el) => el.classList.remove("hidden"));
          document
            .querySelectorAll(".color-scheme-light-icon")
            .forEach((el) => el.classList.add("hidden"));
          localStorage.scheme = 'light'
        } else {
          document.documentElement.classList.add('dark')
          document
            .querySelectorAll(".color-scheme-dark-icon")
            .forEach((el) => el.classList.add("hidden"));
          document
            .querySelectorAll(".color-scheme-light-icon")
            .forEach((el) => el.classList.remove("hidden"));
          localStorage.scheme = 'dark'
        }
      };

      window.toggleScheme = function () {
        if (document.documentElement.classList.contains('dark')) {
          applyScheme("light")
        } else {
          applyScheme("dark")
        }
      }

      window.initScheme = function() {
        if (localStorage.scheme === 'dark' || (!('scheme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
          applyScheme("dark")
        } else {
          applyScheme("light")
        }
      }

      try {
        initScheme()
      } catch (_) {}
    </script>
    """
  end
end
