/** @type {import('tailwindcss').Config} */
module.exports = {
  content: {
    files: ["lib/WebSite/*/*.pm"],
    extract: {
      pm: (content) => {
        const re = /qw\|([^|]+)\|/g;
        let match = content.match(re);

        if (match === null) {
          return [];
        }

        return match
          .map((x) => x.replace(re, "$1"))
          .join(" ")
          .split(/\s+/);
      },
    },
  },
  theme: {
    colors: {
      blue: {
        dark: "#4a5ba6",
        light: "#5fc7ff",
      },

      purple: {
        light: "#6b519d",
      },

      gray: {
        darkest: "#1b1b1b",
        darker: "#262626",
        dark: "#303030",
        clay: "#777777",
        light: "#d4d4d4",
        lighter: "#e2e2e2",
        lightest: "#f1f1f1",
        bright: "#ffffff",
      },
    },
  },
};
