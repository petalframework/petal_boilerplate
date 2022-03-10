// Pairs with color_scheme_switch.ex

window.toggleColorScheme = function () {
  console.log("toggleColorScheme");
  let newColorScheme =
    Cookies.get("color-scheme") === "dark" ? "light" : "dark";
  applyColorScheme(newColorScheme);
};

window.initCurrentColorScheme = function () {
  let colorScheme = Cookies.get("color-scheme");

  if (!colorScheme) {
    colorScheme = window.matchMedia("(prefers-color-scheme: dark)").matches
      ? "dark"
      : "light";
  }

  applyColorScheme(colorScheme);

  document.querySelectorAll(".color-scheme").forEach((el) => {
    el.addEventListener("click", toggleColorScheme);
  });
};

window.applyColorScheme = function (colorScheme) {
  if (colorScheme === "dark") {
    document
      .querySelectorAll(".color-scheme-dark-icon")
      .forEach((el) => el.classList.add("hidden"));
    document
      .querySelectorAll(".color-scheme-light-icon")
      .forEach((el) => el.classList.remove("hidden"));
    document.documentElement.classList.add("dark");
    Cookies.set("color-scheme", "dark", { expires: 9999 });
    console.log("CSS dark theme applied");
  } else {
    document
      .querySelectorAll(".color-scheme-dark-icon")
      .forEach((el) => el.classList.remove("hidden"));
    document
      .querySelectorAll(".color-scheme-light-icon")
      .forEach((el) => el.classList.add("hidden"));
    document.documentElement.classList.remove("dark");
    Cookies.set("color-scheme", "light", { expires: 9999 });
    console.log("CSS light theme applied");
  }
};

window.initCurrentColorScheme();
