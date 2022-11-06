import { loadDefaultJapaneseParser } from "budoux";

const parser = loadDefaultJapaneseParser();
const selector = "p, h1, h2, h3, h4, h5, h6, ul li, dl dt, dl dd"
  .split(", ")
  .map((x) => `.entry__content > ${x}, :not([class~="content__card"]) ${x}`)
  .join(", ");

document.addEventListener("DOMContentLoaded", () => {
  for (el of document.querySelectorAll(selector)) {
    parser.applyElement(el);
  }
});
