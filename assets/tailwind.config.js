const colors = require("tailwindcss/colors");

module.exports = {
  mode: "jit",
  purge: [
    "../lib/*_web/**/*.*ex",
    "./js/**/*.js",
    "../deps/petal_components/**/*.*ex",
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      colors: {
        primary: colors.blue,
        secondary: colors.pink,
      },
    },
  },
  plugins: [require("@tailwindcss/forms")],
};
