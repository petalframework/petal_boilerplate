// Requires window.initScheme() and window.toggleScheme() functions defined (see `color_scheme_switch.ex`)
const ColorSchemeHook = {
  deadViewCompatible: true,
  mounted() {
    this.init();
  },
  updated() {
    this.init();
  },
  init() {
    initScheme();
    this.el.addEventListener("click", window.toggleScheme);
  },
};

export default ColorSchemeHook;
