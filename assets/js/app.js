// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
Alpine.start();

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: {
    DarkThemeSwitch: {
      mounted() {
        if (window.darkThemeSwitchAlreadyRun) {
          applyLocalStorageTheme();
        } else {
          setupDarkThemeSwitch();
        }
      },
    },
  },
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        window.Alpine.clone(from, to);
      }
    },
  },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (info) => topbar.show());
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

function setupDarkThemeSwitch() {
  if (!("color-theme" in localStorage)) {
    let colorTheme = window.matchMedia("(prefers-color-scheme: dark)").matches
      ? "dark"
      : "light";
    localStorage.setItem("color-theme", colorTheme);
  }

  var themeToggleBtn = document.getElementById("theme-toggle");

  themeToggleBtn.addEventListener("click", () => {
    localStorage.setItem(
      "color-theme",
      localStorage.getItem("color-theme") === "dark" ? "light" : "dark"
    );
    applyLocalStorageTheme();
  });

  applyLocalStorageTheme();

  window.darkThemeSwitchAlreadyRun = true;
}

function applyLocalStorageTheme() {
  var themeToggleDarkIcon = document.getElementById("theme-toggle-dark-icon");
  var themeToggleLightIcon = document.getElementById("theme-toggle-light-icon");

  if (localStorage.getItem("color-theme") === "dark") {
    themeToggleLightIcon.classList.remove("hidden");
    themeToggleDarkIcon.classList.add("hidden");
    document.documentElement.classList.add("dark");
    localStorage.setItem("color-theme", "dark");
  } else {
    themeToggleLightIcon.classList.add("hidden");
    themeToggleDarkIcon.classList.remove("hidden");
    document.documentElement.classList.remove("dark");
    localStorage.setItem("color-theme", "light");
  }
}

// This runs on static and live views, however on live views it doesn't work properly and need to use a hook (see above in the LiveSocket setup)
window.onload = () => {
  setupDarkThemeSwitch();
};
