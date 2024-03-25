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
        dark: "#005577",
      },

      gray: {
        darkest: "#222222",
        darker: "#333333",
        dark: "#444444",
        light: "#E7E7E7",
        lighter: "#F0F0F0",
        lightest: "#F7F7F7",
      },
    },
  },
};
