// Pairs with color_scheme_switch.ex
var themeToggleDarkIcon = document.getElementById("color-scheme-dark-icon");
var themeToggleLightIcon = document.getElementById("color-scheme-light-icon");

if (!("color-scheme" in localStorage)) {
  let colorTheme = window.matchMedia("(prefers-color-scheme: dark)").matches
    ? "dark"
    : "light";
  localStorage.setItem("color-scheme", colorTheme);
}

var themeToggleBtn = document.getElementById("color-scheme");

if (themeToggleBtn) {
  themeToggleBtn.addEventListener("click", () => {
    localStorage.setItem(
      "color-scheme",
      localStorage.getItem("color-scheme") === "dark" ? "light" : "dark"
    );
    applyLocalStorageTheme();
  });
}

applyLocalStorageTheme();

function applyLocalStorageTheme() {
  if (localStorage.getItem("color-scheme") === "dark") {
    themeToggleLightIcon && themeToggleLightIcon.classList.remove("hidden");
    themeToggleDarkIcon && themeToggleDarkIcon.classList.add("hidden");
    document.documentElement.classList.add("dark");
    localStorage.setItem("color-scheme", "dark");
    Cookies.set("color-scheme", "dark", { expires: 9999 });
    console.log("CSS dark theme applied");
  } else {
    themeToggleLightIcon && themeToggleLightIcon.classList.add("hidden");
    themeToggleDarkIcon && themeToggleDarkIcon.classList.remove("hidden");
    document.documentElement.classList.remove("dark");
    localStorage.setItem("color-scheme", "light");
    Cookies.set("color-scheme", "light", { expires: 9999 });
    console.log("CSS light theme applied");
  }
}
