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
        light: "#B0E0FF",
        dark: "#0033A0",
      },

      purple: {
        light: "#CC88CC",
      },

      gray: {
        darkest: "#222222",
        darker: "#333333",
        dark: "#444444",
        clay: "#D0D0D0",
        light: "#E7E7E7",
        lighter: "#F0F0F0",
        lightest: "#F7F7F7",
        bright: "#FFFFFF",
      },
    },
  },
};
