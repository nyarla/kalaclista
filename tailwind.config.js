/** @type {import('tailwindcss').Config} */
module.exports = {
  content: {
    files: [
      "./lib/WebSite/Helper/TailwindCSS.pm",
      "./lib/WebSite/Templates/*.pm",
      "./lib/WebSite/Widgets/*.pm",
    ],
    extract: {
      pm: (content) => {
        const matched = content.match(/q[|][^|]+[|]/g);
        const classes = [];

        if (matched !== null) {
          matched.map((src) => {
            src
              .match(/q[|]([^|]+)[|]/)[1]
              .split(" ")
              .map((c) => classes.push(c));
          });
        }

        return classes;
      },
    },
  },
  theme: {
    colors: {
      red: "#FF6633",
      yellow: "#FFCC33",
      teal: "#005588",
      pink: "#CC99CC",

      darkest: "#000000",
      darker: "#333333",

      bright: "#E9E9E9",
      brighter: "#F9F9F9",
      brightest: "#FBFBFB",
    },
    fontFamily: {
      serif: [["serif"], {}],
      sans: [["sans-serif"], {}],
      mono: [["monospace"], {}],
    },
  },
};
