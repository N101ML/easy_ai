const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
      backgroundColor: {
        "custom-bg-main": "#09101d",
        "custom-bg-modal": "#F7F6F0",
        "custom-bg-button": "#CFDBD9",
        "custom-bg-button-hover": "#AEBFBD",
        "custom-bg-filter-list": "#15263a",
        "custom-bg-pagy-list": "#2a4c6c",
      },
      colors: {
        pagyBlue: {
          DEFAULT: "#15263a",
        },
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
  ],
};
