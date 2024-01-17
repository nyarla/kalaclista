/** @type {import('tailwindcss').Config} */
module.exports = {
  content: {
    files: ["./lib/WebSite/Widgets/*.pm", "./lib/WebSite/Templates/*.pm"],
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
      notify: "#FFCC33",
      info: "#33CCFF",
      warn: "#FF6633",

      text: "#333333",
      actionable: "#003399",
      unactionable: "#E9E9E9",
      background: "#F9F9F9",

      darkmodeText: "#F0F0F0",
      darkmodeActionable: "#D0E0FF",
      darkmodeUnactionable: "#003366",
      darkmodeBackground: "#333333",
    },
    fontFamily: {
      serif: [["serif"], { fontFeatureSettings: '"palt"' }],
      sans: [["sans-serif"], { fontFeatureSettings: '"palt"' }],
    },
  },
};
