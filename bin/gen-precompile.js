"use strict";

const { spawn } = require("node:child_process");

const { dirname, normalize } = require("node:path");
const { createReadStream } = require("node:fs");
const { createInterface } = require("node:readline/promises");
const { mkdir, writeFile } = require("node:fs/promises");

const cluster = require("node:cluster");
const { availableParallelism } = require("node:os");

const { loadDefaultJapaneseParser } = require("budoux");
const { minify } = require("html-minifier");

const rootdir = dirname(process.argv[1]) + "/..";
const budoux = loadDefaultJapaneseParser();

const numCPUs = availableParallelism();

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
  const cmark = spawn(
    "cmark-gfm",
    [
      "--unsafe",
      "--to",
      "html",
      "-e",
      "strikethrough",
      "--strikethrough-double-tilde",
    ],
    {
      shell: true,
      stdio: ["pipe", "pipe", "inherit"],
    },
  );

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
  return mkdir(dirname(filepath), { recursive: true }).then(() =>
    writeFile(filepath, html, { encoding: "utf8", mode: 0o644 }),
  );
}

function leader(fileset) {
  let total = 0;
  for (let files of fileset) {
    if (!files) {
      continue;
    }

    total += files.length;

    let worker = cluster.fork();
    worker.on("online", () => {
      worker.send(files);
    });
  }

  return new Promise((resolve) => {
    let count = 0;
    cluster.on("message", (worker, message, handle) => {
      count++;
      if (count === total) {
        resolve();
      }
    });
  });
}

function worker() {
  process.on("message", async function (files) {
    const done = [];

    for (let file of files) {
      console.log(file);
      done.push(compile(file));
    }

    process.send(Promise.allSettled(done));
    cluster.worker.disconnect();
  });
}

function lookup(src) {
  const reader = createInterface(createReadStream(src));
  const fileset = new Array(numCPUs);

  let idx = 0;
  reader.on("line", (file) => {
    if (idx === fileset.length) {
      idx = 0;
    }

    if (!Array.isArray(fileset[idx])) {
      fileset[idx] = [];
    }

    fileset[idx].push(file);

    idx++;
  });

  return new Promise((resolve) => {
    reader.on("close", () => {
      resolve(fileset);
    });
  });
}

async function main(src) {
  if (cluster.isPrimary) {
    const fileset = await lookup(src);
    await leader(fileset);
  } else {
    worker();
  }
}

main(process.argv[2]);
