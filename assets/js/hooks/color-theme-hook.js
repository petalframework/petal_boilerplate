// Requires color-scheme-switch.js to have been loaded
// Add this to your theme switcher button
const ColorThemeHook = {
  mounted() {
    this.el.addEventListener("click", window.toggleColorScheme);
  },
};

export default ColorThemeHook;
