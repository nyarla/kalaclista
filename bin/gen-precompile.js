"use strict";

const { spawn } = require("node:child_process");

const { dirname, normalize } = require("node:path");
const { createReadStream } = require("node:fs");
const { createInterface } = require("node:readline/promises");
const { writeFile } = require("node:fs/promises");

const { loadDefaultJapaneseParser } = require("budoux");
const { minify } = require("html-minifier");

const rootdir = dirname(process.argv[1]) + "/..";
const budoux = loadDefaultJapaneseParser();

function fullpath(path) {
  return normalize(`${rootdir}/content/entries/${path}`);
}

function load(path) {
  const filepath = fullpath(path);
  const reader = createInterface(createReadStream(filepath));

  return new Promise((resolve, _) => {
    let data = "";
    let inside = false;
    let num = 0;

    reader.on("line", (line) => {
      if (line === "---") {
        if (num === 0 && !inside) {
          inside = true;
          return;
        }

        if (num > 0 && inside) {
          inside = false;
          return;
        }
      }

      if (!inside) {
        data += line + "\n";
      }

      num++;
    });

    reader.on("close", () => resolve(data));
  });
}

function compaction(html) {
  return minify(html, {
    collapseWhitespace: true,
    continueOnParseError: true,
    continueOnParseError: true,
    html5: true,
    minifyCSS: true,
    preventAttributesEscaping: true,
    processConditionalComments: true,
    removeAttributeQuotes: true,
    removeComments: true,
    removeEmptyAttributes: true,
    removeEmptyElements: true,
    removeOptionalTags: true,
    removeRedundantAttributes: true,
    removeTagWhitespace: true,
    sortAttributes: true,
    sortClassName: true,
  });
}

async function compile(fn) {
  const content = await load(fn);
  const cmark = spawn("cmark", ["--unsafe", "--to", "html"], {
    shell: true,
    stdio: ["pipe", "pipe", "inherit"],
  });

  cmark.stdin.write(content);
  cmark.stdin.end();

  let out = "";
  for await (const str of cmark.stdout) {
    out += str.toString("utf8");
  }

  const html = compaction(
    budoux
      .translateHTMLString(out)
      .replace(/<\/?span>/g, "")
      .replace("に<wbr>ゃるら", "にゃるら")
      .replace(/overflow-wrap: break-word/g, "overflow-wrap: anywhere") + "\n",
  );

  const filepath = fullpath(fn).replace("/entries/", "/precompiled/");
  return writeFile(filepath, html, { encoding: "utf8", mode: 0o644 });
}

async function main(file) {
  const files = createInterface(createReadStream(file));

  let queues = [];

  files.on("line", async function (fn) {
    console.log(fn);
    queues.push(compile(fn));
  });

  await Promise.all(queues);
}

main(process.argv[2]);
