const colors = require("tailwindcss/colors");

module.exports = {
  mode: "jit",
  purge: ["../lib/*_web/**/*.*ex", "./js/**/*.js"],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      colors: {
        primary: colors.blue,
        secondary: colors.pink,
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
