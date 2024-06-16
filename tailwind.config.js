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
        dark: "#2050b9",
        light: "#5fc7ff",
      },

      orange: {
        dark: "#ff7e23",
        light: "#9a2b0f",
      },

      purple: {
        dark: "#8f248c",
        light: "#efa6ff",
      },

      gray: {
        darkest: "#111111",
        darker: "#1b1b1b",
        dark: "#262626",
        clay: "#777777",
        light: "#e2e2e2",
        lighter: "#f1f1f1",
        lightest: "#ffffff",
      },
    },
  },
};
