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
};
